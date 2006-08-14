From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Mon, 14 Aug 2006 13:15:17 -0700 (PDT)
Message-ID: <20060814.131517.125893128.davem@davemloft.net>
References: <9286.1155557268@ocs10w.ocs.com.au>
	<20060814122049.GC18321@2ka.mipt.ru>
	<44E0B61F.3000706@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, kaos@ocs.com.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59803
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932696AbWHNUPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 16:15:20 -0400
To: rick.jones2@hp.com
In-Reply-To: <44E0B61F.3000706@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 14 Aug 2006 10:42:55 -0700

> Now, PA-RISC CPUs have the ability to disable spaceid hashing, and it is 
> entirely possible that the PA-RISC linux port does that, but I thought I 
> would mention it as an example.  I'm sure the "official" PA-RISC linux 
> folks can expand on that much much better than I can.

Regardless, the "offset" it usually taken care of transparently
by the kernel in order to avoid cache aliasing issues.

It is definitely something we'll need to deal with for zero-copy
I/O using NTA.  We'll have to make sure that the user mapping of
the page is of the same color as the mapping the kernel uses.
