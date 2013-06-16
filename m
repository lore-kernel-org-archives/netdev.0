From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: Re: [RFC PATCH] usb: hcd: warn about URB buffers that are not DMA
 aligned and are about to be DMA mapped
Date: Sun, 16 Jun 2013 13:35:33 +0300
Message-ID: <51BD94F5.2060803@iki.fi>
References: <20130614133803.25747.98705.stgit@localhost6.localdomain6> <51BC67D7.90006@iki.fi> <51BC6A96.7030707@iki.fi> <6777683.xBFsv58ruI@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <tom.leiming@gmail.com>, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Network Development <netdev@vger.kernel.org>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sinikuusama.dnainternet.net ([83.102.40.134]:56359 "EHLO
	sinikuusama.dnainternet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755142Ab3FPKfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 06:35:40 -0400
In-Reply-To: <6777683.xBFsv58ruI@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.06.2013 11:21, Oliver Neukum wrote:
> On Saturday 15 June 2013 16:22:30 Jussi Kivilinna wrote:
> 
>> Hm.. rethink this a bit.
>>
>> Transfer buffer might be dma aligned but shorter than cacheline and end of cacheline
>> used as something else. Manual alignment by host driver does not catch that
>> or fix that.
>> So, yes.. dma mapping should work with unaligned buffers, but maybe the actual
>> problem is multiple buffers from same cacheline.
> 
> The buffers kmalloc() returns are OK in that regard. A driver that uses
> a buffer for anything but buffering is buggy.

Ok, I'll look at that direction. Thanks.

-Jussi

> 
> 	Regards
> 		Oliver
> 
> 
