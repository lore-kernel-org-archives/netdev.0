From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Don't allow sharing of tx skbs on xen-netfront
Date: Mon, 14 Nov 2011 14:32:33 -0500
Message-ID: <20111114193233.GD27284@hmsreliant.think-freely.org>
References: <1321298544-16434-1-git-send-email-nhorman@tuxdriver.com>
 <20111114.142716.615003966880410697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeremy.fitzhardinge@citrix.com,
	konrad.wilk@oracle.com, xen-devel@lists.xensource.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57506 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab1KNTci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:32:38 -0500
Content-Disposition: inline
In-Reply-To: <20111114.142716.615003966880410697.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2011 at 02:27:16PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 14 Nov 2011 14:22:24 -0500
> 
> > It was pointed out to me recently that the xen-netfront driver can't safely
> > support shared skbs on transmit, since, while it doesn't maintain skb state
> > directly, it does pass a pointer to the skb to the hypervisor via a list, and
> > the hypervisor may expect the contents of the skb to remain stable.  Clearing
> > the IFF_TX_SKB_SHARING flag after the call to alloc_etherdev to make it safe.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Please put an appropriate prefix into the subject lines of your patch
> submissions.  In this case "[PATCH] xen-netfront: ..." would be appropriate.
> 
> I've been letting you get away with this for the past few weeks and I've
> decided that it's your turn to start getting this right :-)
Jeez Dave, I got it right on the cgroups post, you want consistency now
too?  :).

Apologies, I need to consult a checklist for myself prior to sending stuff.

Best
Neil



> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
