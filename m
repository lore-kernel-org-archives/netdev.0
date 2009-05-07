From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH] remove DMA_nBIT_MASK macro
Date: Fri, 8 May 2009 08:35:21 +0900
Message-ID: <20090508083610Z.fujita.tomonori@lab.ntt.co.jp>
References: <20090506223452.65e545d8.akpm@linux-foundation.org>
	<4A029BE1.4090309@cn.fujitsu.com>
	<4A029FD1.1050007@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanghy@cn.fujitsu.com, akpm@linux-foundation.org,
	fujita.tomonori@lab.ntt.co.jp, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: jirislaby@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759889AbZEGXhp@vger.kernel.org>
In-Reply-To: <4A029FD1.1050007@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 07 May 2009 10:46:09 +0200
Jiri Slaby <jirislaby@gmail.com> wrote:

> On 05/07/2009 10:29 AM, Yang Hongyang wrote:
> > Shall we use something like below to warn people?
> > #define DMA_64BIT_MASK	DMA_BIT_MASK(64);(__deprecated warnings:use DMA_BIT_MASK(64) instead) ?
> 
> Something like an irq flags deprecation in the past:
> http://lwn.net/Articles/229673/
> ?
> 
> I don't know how many in-initializer (struct x x = { DMA_64BIT_MASK } )
> users are out there though.

Unfortunately, there are lots. Converting these macros to functions
would breaks drivers too.
