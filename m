From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [patch 01/11] e1000: memory leak in e1000_set_ringparam()
Date: Mon, 25 Sep 2006 21:57:50 -0700
Message-ID: <4518B34E.1040707@intel.com>
References: <200609252339.k8PNdFO1002622@shell0.pdx.osdl.net> <45186E09.1080003@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, vvs@sw.ru,
	auke-jan.h.kok@intel.com, cramerj@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:8722 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1750898AbWIZE7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 00:59:40 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45186E09.1080003@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> akpm@osdl.org wrote:
>> From: Vasily Averin <vvs@sw.ru>
>>
>> Memory leak was found in 2.6.18-rc4 and e1000 7.2.7 from sourceforge:
>> Memory allocated for new tx_ring and rx_ring leaks if
>> e1000_setup_XX_resources() fails.c Also this patch reduces stack usage
>> (removed tx_new and rx_new) and uses kzalloc instead kmalloc+memset(0)
>>
>> Signed-off-by: Vasily Averin <vvs@sw.ru>
>> Cc: Jeb Cramer <cramerj@intel.com>
>> Cc: John Ronciak <john.ronciak@intel.com>
>> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Cc: Auke Kok <auke-jan.h.kok@intel.com>
>> Cc: Jeff Garzik <jeff@garzik.org>
>> Signed-off-by: Andrew Morton <akpm@osdl.org>
> 
> ACK + HOLD, waiting to see if this will be included in Auke's push

Ack, I've stacked it on the workqueue and it will go out to Jeff this week.

Cheers,

Auke
