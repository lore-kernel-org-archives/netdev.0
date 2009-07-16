From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Debounce code vs. dma_sync_single_range_for_cpu() and e100
	driver.
Date: Thu, 16 Jul 2009 15:27:01 -0700
Message-ID: <9929d2390907161527v6ae2751fy31957b643ee0cd88@mail.gmail.com>
References: <m3d483m53q.fsf@intrepid.localdomain>
	 <20090714.123848.189674670.davem@davemloft.net>
	 <m38wirm119.fsf@intrepid.localdomain>
	 <20090714.140507.211725964.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:15638 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932998AbZGPW1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 18:27:02 -0400
Received: by qw-out-2122.google.com with SMTP id 8so191722qwh.37
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 15:27:02 -0700 (PDT)
In-Reply-To: <20090714.140507.211725964.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2009 at 2:05 PM, David Miller<davem@davemloft.net> wrote:
> From: Krzysztof Halasa <khc@pm.waw.pl>
> Date: Tue, 14 Jul 2009 23:01:54 +0200
>
>> Maybe you apply the workaround for 2.6.31 and I (or someone) will
>> convert e100 to coherent allocs for packet descriptors, post-31?
>
> I think that's a good plan.
>
> Will give a few days for Intel folks to chime in before applying
> your patch for 2.6.31, but otherwise that's my plan.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-- 
Cheers,
Jeff
