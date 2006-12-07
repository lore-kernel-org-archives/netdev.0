From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.19] AT91RM9200 Ethernet update 3
Date: Thu, 7 Dec 2006 09:19:57 -0800
Message-ID: <20061207091957.390e68a3@freekitty>
References: <1165236624.4606.111.camel@fuzzie.sanpeople.com>
	<20061204100831.0af6790f@freekitty>
	<1165303792.12510.55.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:47285 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162556AbWLGRUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 12:20:53 -0500
To: Andrew Victor <andrew@sanpeople.com>
In-Reply-To: <1165303792.12510.55.camel@fuzzie.sanpeople.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05 Dec 2006 09:29:52 +0200
Andrew Victor <andrew@sanpeople.com> wrote:

> hi Stephen,
> 
> > Use netdev_alloc_skb instead. It sets skb->dev so you don't have to.
> 
> netdev_alloc_skb() seems to cause 2 function calls [__netdev_alloc_skb()
> and __alloc_skb()], instead of just 1 for the dev_alloc_skb() case.
> It might be more efficient if the driver manually sets skb->dev.

That is trivial, and netdev_alloc_skb() is setup to handle other
issues in future.


-- 
Stephen Hemminger <shemminger@osdl.org>
