From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: netif_tx_disable and lockless TX
Date: Tue, 30 May 2006 22:30:25 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC041BC92@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:11795 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751584AbWEaFaj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 01:30:39 -0400
Content-class: urn:content-classes:message
To: "David Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 31 May 2006 14:58:11 +1000
> 
> > Yes, TG3 does not disable IRQs when taking its TX lock.  So do you
see
> > any problems with replacing the TG3 TX lock using xmit_lock?
> 
> I don't see any.
> 

I also don't see any problem. It looks like we don't have to set
xmit_lock_owner, right?

