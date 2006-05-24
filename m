From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: Re: [PATCH 2/4] b44: wol setup for older 4401
Date: Wed, 24 May 2006 08:33:21 -0700
Message-ID: <1148484801.2976.67.camel@dhcp-10-7-81-7.broadcom.com>
References: <1148481647.2976.52.camel@dhcp-10-7-81-7.broadcom.com>
 <20060524221306.GB2863@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:19729 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S964781AbWEXWfH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 18:35:07 -0400
To: "Francois Romieu" <romieu@fr.zoreil.com>
In-Reply-To: <20060524221306.GB2863@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-05-25 at 00:13 +0200, Francois Romieu wrote:

> > +	pwol_pattern = kmalloc(B44_WOL_PATTERN_SIZE, GFP_KERNEL);
> > +	pwol_mask = kmalloc(B44_WOL_MASK_SIZE, GFP_KERNEL);
> > +
> kmalloc can fail. It should be checked.
Yep. Thanks.

> > +	max = ETH_ALEN;
> > +	for (i = 0; i < 14; ++i) {
> > +		if (i == 13)
> > +			max = 2;
> > +		for (j = 0; j < max; ++j) {
> > +			pwol_pattern[42 + 6 +
> > +			(i * ETH_ALEN) + j] =
> > +			bp->dev->dev_addr[j];
> 
> Indentation went strange here.
> 
Will adjust.
Thanks.

