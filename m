From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/6] vxlan: Only bind to sockets with correct extensions
 enabled
Date: Wed, 7 Jan 2015 22:52:52 +0000
Message-ID: <20150107225252.GA21149@casper.infradead.org>
References: <cover.1420594925.git.tgraf@suug.ch>
 <46b4ceefbd8513250f64ba9c7297a8d2743f3108.1420594925.git.tgraf@suug.ch>
 <CAEP_g=8_BFYO67Qj+TQUprqomBrwPLSGJvA3+F=9E3bgKhcrEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37946 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbbAGWwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 17:52:54 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=8_BFYO67Qj+TQUprqomBrwPLSGJvA3+F=9E3bgKhcrEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/15 at 02:45pm, Jesse Gross wrote:
> On Tue, Jan 6, 2015 at 6:05 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > A VXLAN net_device looking for an appropriate socket may only
> > consider a socket which has the exact set of extensions enabled.
> > If none can be found, a new socket must be created.
> 
> Maybe it's just the phrasing of the commit message but won't the new
> socket that needs to be created immediately fail? I think this is
> really just checking that you don't try to instantiate two different
> sets of extensions on the same UDP port - it's not like this is going
> to somehow create a new socket and they will be able to coexist.

Your interpretation is correct and the phrasing is poor. It prevents
a non-GBP socket from being used for a GBP socket. I will rework the
commit message.
