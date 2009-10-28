From: fangxiaozhi 00110321 <huananhu@huawei.com>
Subject: Re: PATCH 23/10]Optimize the upload speed for PPP connection.
Date: Wed, 28 Oct 2009 15:30:45 +0800
Message-ID: <fb8ed0e9a479.a479fb8ed0e9@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, kernel@vger.kernel.org, zihan@huawei.com,
	greg@kroah.com, haegar@sdinet.de
To: davem@davemloft.net, william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:41793 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932392AbZJ1Han (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 03:30:43 -0400
Content-language: zh-CN
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks your advice.

But generally, PAGE_SIZE is 4096, whether it is too large or not?

If PAGE_SIZE is really appropriate, then I can resubmit the patch.

Thanks very much.
----- Original Message ----- 
From: "David Miller" <davem@davemloft.net>
To: <william.allen.simpson@gmail.com>
Cc: <huananhu@huawei.com>; <netdev@vger.kernel.org>; <linux-kernel@vger.kernel.org>; <zihan@huawei.com>; <greg@kroah.com>; <haegar@sdinet.de>
Sent: Saturday, October 24, 2009 9:46 PM
Subject: Re: PATCH 23/10]Optimize the upload speed for PPP connection.


> From: William Allen Simpson <william.allen.simpson@gmail.com>
> Date: Fri, 23 Oct 2009 07:46:08 -0400
> 
>> Concur.  I'd go further than that, my code usually made room for at
>> least
>> a full MTU (MRU) with HDLC escaping.  To minimize context switches,
>> that
>> should be 3014 ((1500 MRU + 2 FCS + 4 header) * 2 escapes + 2 flags).
>> 
>> Even in the old days, when memory was tight, context switches and
>> interrupt
>> time were more expensive, too.  PPP is supposed to scale to OC-192.
> 
> Actually I'd like to see ->obuf allocated externally and then
> make it simply PAGE_SIZE.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
******************************************************************************************
 This email and its attachments contain confidential information from HUAWEI, which is intended only for the person or entity whose address is listed above. Any use of the information contained here in any way (including, but not limited to, total or partial disclosure, reproduction, or dissemination) by persons other than the intended recipient(s) is prohibited. If you receive this email in error, please notify the sender by phone or email
 immediately and delete it!
 *****************************************************************************************
