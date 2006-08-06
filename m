From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 6 Aug 2006 10:20:12 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FA17@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <20060805230517.GA25468@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, shemminger@osdl.org,
	jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:44037 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1750827AbWHFRUe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 13:20:34 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20060805230517.GA25468@gondor.apana.org.au>
To: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"jamal" <hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

> In fact that reminds me, because tg3 is no longer lockless, we can do
> a nicer bug fix for it than e1000 (it has the same bug).
> 

Do you mean the same race condition bug between tg3_start_xmit()
and tg3_tx() that I brought up?  I don't think tg3 has that problem.
Did I miss something?

