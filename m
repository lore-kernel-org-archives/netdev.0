From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_core: Test interrupts fail if not
 all comp vectors called request_irq
Date: Mon, 05 Oct 2015 23:24:05 -0700 (PDT)
Message-ID: <20151005.232405.779019414670229234.davem@davemloft.net>
References: <1443551891-17971-1-git-send-email-clsoto@linux.vnet.ibm.com>
	<5610DD46.204@mellanox.com>
	<56129623.3060800@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org,
	brking@linux.vnet.ibm.com, amirv@mellanox.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbbJFGIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 02:08:25 -0400
In-Reply-To: <56129623.3060800@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol Soto <clsoto@linux.vnet.ibm.com>
Date: Mon, 5 Oct 2015 10:24:19 -0500

> 
> 
> On 10/4/2015 3:03 AM, Or Gerlitz wrote:
>> On 9/29/2015 9:38 PM, clsoto@linux.vnet.ibm.com wrote:
>>> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>>>
>>> Test interrupts fails if not all completion vectors called
>>> request_irq. This case can happen if only mlx4_en loads and
>>> we have more completion vectors than rx rings.
>>
>> good catch! is this a bug since the driver 0-day or was introduced by
>> some recent commit? in the latercase, please add a Fixes: tag before
>> your S.O.B note.
> Probably the issue was introduced by this one
> Fixes: c66fa19c405a ('net/mlx4: Add EQ pool')

Please resubmit this patch with the Fixes: tag properly
added, thanks.
