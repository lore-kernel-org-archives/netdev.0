From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] remove DMA_nBIT_MASK macro
Date: Thu, 07 May 2009 16:59:04 +0800
Message-ID: <4A02A2D8.4090209@cn.fujitsu.com>
References: <20090507141114M.fujita.tomonori@lab.ntt.co.jp> <20090506223452.65e545d8.akpm@linux-foundation.org> <4A029BE1.4090309@cn.fujitsu.com> <4A029FD1.1050007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56127 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755419AbZEGI6H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2009 04:58:07 -0400
In-Reply-To: <4A029FD1.1050007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Slaby wrote:
> On 05/07/2009 10:29 AM, Yang Hongyang wrote:
>> Shall we use something like below to warn people?
>> #define DMA_64BIT_MASK	DMA_BIT_MASK(64);(__deprecated warnings:use DMA_BIT_MASK(64) instead) ?
> 
> Something like an irq flags deprecation in the past:
> http://lwn.net/Articles/229673/
> ?

good catch,but this need to be modified (add one line is enough)to cause their use to
cause __deprecated warnings.

> 
> I don't know how many in-initializer (struct x x = { DMA_64BIT_MASK } )
> users are out there though.
> 
> 


-- 
Regards
Yang Hongyang
