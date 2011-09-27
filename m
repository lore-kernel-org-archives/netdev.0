From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] staging/octeon: Software should check the checksum of no
 tcp/udp packets
Date: Mon, 26 Sep 2011 17:51:27 -0700
Message-ID: <20110927005127.GB10447@kroah.com>
References: <1316999280-11999-1-git-send-email-rongqing.li@windriver.com>
 <4E80D794.3040701@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rongqing.li@windriver.com, netdev@vger.kernel.org,
	ralf@linux-mips.org, David Miller <davem@davemloft.net>,
	linux-mips@linux-mips.org
To: David Daney <david.daney@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4.smtp.messagingengine.com ([66.111.4.28]:44737 "EHLO
	out4.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751387Ab1I0AxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 20:53:04 -0400
Content-Disposition: inline
In-Reply-To: <4E80D794.3040701@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2011 at 12:50:44PM -0700, David Daney wrote:
> On 09/25/2011 06:08 PM, rongqing.li@windriver.com wrote:
> >From: Roy.Li<rongqing.li@windriver.com>
> >
> >Icmp packets with wrong checksum are never dropped since
> >skb->ip_summed is set to CHECKSUM_UNNECESSARY.
> >
> >When icmp packets with wrong checksum pass through the octeon
> >net driver, the not_IP, IP_exc, L4_error hardware indicators
> >show no error. so the driver sets CHECKSUM_UNNECESSARY on
> >skb->ip_summed.
> >
> >L4_error only works for TCP/UDP, not for ICMP.
> >
> >Signed-off-by: Roy.Li<rongqing.li@windriver.com>
> 
> We found the same problem, but have not yet sent the patch to fix it.
> 
> This looks fine to me,
> 
> Acked-by: David Daney <david.daney@cavium.com>
> 
> I would let davem, Ralf and Greg KH fight over who gets to merge it.

I'll let Ralf take it, unless he wants me to.

Ralf?
