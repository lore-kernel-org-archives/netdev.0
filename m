From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] s2io: Remove unnecessary casts
Date: Thu, 13 Aug 2009 20:14:52 -0700 (PDT)
Message-ID: <20090813.201452.21119996.davem@davemloft.net>
References: <20090814020328.GA21588@fencepost.gnu.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ram.vepa@neterion.com, santosh.rastapur@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com,
	anil.murthy@neterion.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dave@gnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34466
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756010AbZHNDOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 23:14:41 -0400
In-Reply-To: <20090814020328.GA21588@fencepost.gnu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davidlohr Bueso <dave@gnu.org>
Date: Thu, 13 Aug 2009 22:03:28 -0400

> 
> No need to cast kmalloc.
> 
> Signed-off-by: Davidlohr Bueso <dave@gnu.org>

Yeah but:

>  
> -                                       ba->ba_0_org = (void *) kmalloc
> -                                           (BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
> +                                       ba->ba_0_org = kmalloc(BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);

Now the code line extends way over 80 columns.

Please fix this up and resubmit.
