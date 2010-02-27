From: Robert Hancock <hancockrwd@gmail.com>
Subject: Re: [RFC PATCH] fix problems with NETIF_F_HIGHDMA in networking
	drivers
Date: Sat, 27 Feb 2010 12:15:19 -0600
Message-ID: <51f3faa71002271015i7c9ec45j18381b1269bfd799@mail.gmail.com>
References: <51f3faa71002261908y7cfa62eeicb3e56d5c920887a@mail.gmail.com>
	 <20100227.015350.71138134.davem@davemloft.net>
	 <201002271259.31596.bzolnier@gmail.com>
	 <20100227.040502.182574085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bzolnier@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100227.040502.182574085.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 27, 2010 at 6:05 AM, David Miller <davem@davemloft.net> wrote:
> From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> Date: Sat, 27 Feb 2010 12:59:31 +0100
>
>> Having IOMMU (even if it is only a software one, i.e. this would
>> mean swiotlb for x86-32/highmem) always in place would simplify
>> things greatly..
>
> I agree, things would be a lot simpler.

Yeah, the situation kind of sucks on the platforms that don't have any
IOMMU support, since it means that the DMA API can't handle anything
over 4GB properly and you need all these hacks in the block layer,
networking layer, etc. It would be nice if some kind of IOMMU support
could be relied upon always.
