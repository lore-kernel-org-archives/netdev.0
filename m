From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 3/6] vxlan: Only bind to sockets with correct extensions enabled
Date: Wed, 7 Jan 2015 14:45:54 -0800
Message-ID: <CAEP_g=8_BFYO67Qj+TQUprqomBrwPLSGJvA3+F=9E3bgKhcrEA@mail.gmail.com>
References: <cover.1420594925.git.tgraf@suug.ch> <46b4ceefbd8513250f64ba9c7297a8d2743f3108.1420594925.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:39224 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750865AbbAGWqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 17:46:15 -0500
Received: by mail-qc0-f177.google.com with SMTP id x3so1610755qcv.8
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 14:46:15 -0800 (PST)
In-Reply-To: <46b4ceefbd8513250f64ba9c7297a8d2743f3108.1420594925.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 6:05 PM, Thomas Graf <tgraf@suug.ch> wrote:
> A VXLAN net_device looking for an appropriate socket may only
> consider a socket which has the exact set of extensions enabled.
> If none can be found, a new socket must be created.

Maybe it's just the phrasing of the commit message but won't the new
socket that needs to be created immediately fail? I think this is
really just checking that you don't try to instantiate two different
sets of extensions on the same UDP port - it's not like this is going
to somehow create a new socket and they will be able to coexist.
