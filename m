From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: bnx2x machine check in bnx2x_ack_int()
Date: Mon, 15 Dec 2008 10:03:29 +0200
Message-ID: <1229328209.22295.16.camel@lb-tlvb-eliezer>
References: <200812091204.35296.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Bjorn Helgaas" <bjorn.helgaas@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4338 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754307AbYLOIFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 03:05:14 -0500
In-Reply-To: <200812091204.35296.bjorn.helgaas@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bjon,

My sincere apologize for the late response. When searching the mailing
list to see if I accidentally missed your reply, I have come to realize
that my response was never sent (problem with my email client).

On Tue, 2008-12-09 at 11:04 -0800, Bjorn Helgaas wrote:
> Hi Eilon,
> 
> I'm using bnx2x 1.45.23 from RHEL5.3s4 on a prototype ia64 platform,
> and I see intermittent machine checks at bnx2x_ack_int+176, which is
> just after __ia64_readl() returns.
I see that you are using two 57710 chips. What kind of board are you
using (which PHY)?

> This is a proto with incomplete firmware, and the driver correctly
> complains about that, but it seems like there's still a hole where
> things blow up.
If you set the right FW on the board, do you still see the problem? I'm
asking to determine if this is a problem specific to the "no FW" case or
general issue with this configuration

> The machine check happens intermittently on boot, but I can reproduce
> it instantly with a loop like this:
> 
>   # while /bin/true; do ifup eth6; date; done
> 
> Here's some lspci and dmesg information.  I added a little debug in
> bnx2x_ack_int(), so this is a kernel I compiled myself.
> 
> Let me know if there's any information I can collect or testing I
> can do.
Unfortunately, with the 57711 Mezzanine on the IA64 blade that I have, I
cannot reproduce this failure, so I will probably need more information.
Can you please send me the nvram content?

Thanks,
Eilon


