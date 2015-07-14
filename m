From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 18/22] openvswitch: Make tunnel set action attach
 a metadata dst
Date: Tue, 14 Jul 2015 11:30:00 +0200
Message-ID: <20150714093000.GB20597@pox.localdomain>
References: <cover.1436537414.git.tgraf@suug.ch>
 <db45b60a2ab4aa0d6dde363558ebe3e46edb0e81.1436537414.git.tgraf@suug.ch>
 <CANr6G5zNyGsx590AqAjYmYeXu0bktnqzO0d-=Yh2_u+iq=LCww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>, daniel@iogearbox.net,
	tom@herbertland.com, edumazet@google.com, jiri@resnulli.us,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	Justin Pettit <jpettit@nicira.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:33269 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbbGNJaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 05:30:03 -0400
Received: by wgmn9 with SMTP id n9so3875857wgm.0
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 02:30:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CANr6G5zNyGsx590AqAjYmYeXu0bktnqzO0d-=Yh2_u+iq=LCww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/15 at 03:55pm, Joe Stringer wrote:
> It doesn't look like flow_free() is using this new function to
> properly free the actions. Also, some of the error cases that hit this
> code have sf_acts=NULL.

Good catch. Will fix in next iteration.
