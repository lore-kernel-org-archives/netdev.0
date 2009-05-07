From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH] remove DMA_nBIT_MASK macro
Date: Thu, 07 May 2009 10:46:09 +0200
Message-ID: <4A029FD1.1050007@gmail.com>
References: <20090507141114M.fujita.tomonori@lab.ntt.co.jp> <20090506223452.65e545d8.akpm@linux-foundation.org> <4A029BE1.4090309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:23201 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbZEGIqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 04:46:18 -0400
In-Reply-To: <4A029BE1.4090309@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2009 10:29 AM, Yang Hongyang wrote:
> Shall we use something like below to warn people?
> #define DMA_64BIT_MASK	DMA_BIT_MASK(64);(__deprecated warnings:use DMA_BIT_MASK(64) instead) ?

Something like an irq flags deprecation in the past:
http://lwn.net/Articles/229673/
?

I don't know how many in-initializer (struct x x = { DMA_64BIT_MASK } )
users are out there though.
