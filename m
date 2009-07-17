From: David Miller <davem@davemloft.net>
Subject: Re: Debounce code vs. dma_sync_single_range_for_cpu() and e100
 driver.
Date: Thu, 16 Jul 2009 18:09:26 -0700 (PDT)
Message-ID: <20090716.180926.149617102.davem@davemloft.net>
References: <m38wirm119.fsf@intrepid.localdomain>
	<20090714.140507.211725964.davem@davemloft.net>
	<9929d2390907161527v6ae2751fy31957b643ee0cd88@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, e1000-devel@lists.sourceforge.net
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38025
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933887AbZGQBJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 21:09:22 -0400
In-Reply-To: <9929d2390907161527v6ae2751fy31957b643ee0cd88@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 16 Jul 2009 15:27:01 -0700

> On Tue, Jul 14, 2009 at 2:05 PM, David Miller<davem@davemloft.net> wrote:
>> From: Krzysztof Halasa <khc@pm.waw.pl>
>> Date: Tue, 14 Jul 2009 23:01:54 +0200
>>
>>> Maybe you apply the workaround for 2.6.31 and I (or someone) will
>>> convert e100 to coherent allocs for packet descriptors, post-31?
>>
>> I think that's a good plan.
>>
>> Will give a few days for Intel folks to chime in before applying
>> your patch for 2.6.31, but otherwise that's my plan.
> 
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, and queued for -stable, thanks everyone.
