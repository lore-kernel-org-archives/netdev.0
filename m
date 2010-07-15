From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/sched: potential data corruption
Date: Wed, 14 Jul 2010 17:56:45 -0700 (PDT)
Message-ID: <20100714.175645.189713068.davem@davemloft.net>
References: <20100713132152.GL5658@bicker>
	<1279036694.16376.0.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, matthew@wil.cx
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38987
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757577Ab0GOA43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 20:56:29 -0400
In-Reply-To: <1279036694.16376.0.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Tue, 13 Jul 2010 11:58:14 -0400

> On Tue, 2010-07-13 at 15:21 +0200, Dan Carpenter wrote:
>> The reset_policy() does:
>>         memset(d->tcfd_defdata, 0, SIMP_MAX_DATA);
>>         strlcpy(d->tcfd_defdata, defdata, SIMP_MAX_DATA);
>> 
>> In the original code, the size of d->tcfd_defdata wasn't fixed and if
>> strlen(defdata) was less than 31, reset_policy() would cause memory
>> corruption.
>> 
>> Please Note:  The original alloc_defdata() assumes defdata is 32
>> characters and a NUL terminator while reset_policy() assumes defdata is
>> 31 characters and a NUL.  This patch updates alloc_defdata() to match
>> reset_policy() (ie a shorter string).  I'm not very familiar with this
>> code so please review carefully.
>> 
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> 
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied, thanks.
