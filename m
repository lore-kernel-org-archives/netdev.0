From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] net: irda: using kzalloc() instead of kmalloc() to avoid
 strncpy() issue.
Date: Mon, 20 May 2013 09:04:42 +0800
Message-ID: <519976AA.2010901@asianux.com>
References: <5195F4A0.3000708@asianux.com> <20130519.151112.787320797896644755.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:57008 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754928Ab3ETBFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 21:05:33 -0400
In-Reply-To: <20130519.151112.787320797896644755.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2013 06:11 AM, David Miller wrote:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Fri, 17 May 2013 17:13:04 +0800
> 
>> > 
>> > 'discovery->data.info' length is 22, NICKNAME_MAX_LEN is 21, so the
>> > strncpy() will always left the last byte of 'discovery->data.info'
>> > uninitialized.
>> > 
>> > When 'text' length is longer than 21 (NICKNAME_MAX_LEN), if still left
>> > the last byte of 'discovery->data.info' uninitialized, the next
>> > strlen() will cause issue.
>> > 
>> > Also 'discovery->data' is 'struct irda_device_info' which defined in
>> > "include/uapi/...", it may copy to user mode, so need whole initialized.
>> > 
>> > All together, need use kzalloc() instead of kmalloc() to initialize all
>> > members firstly.
>> > 
>> > Signed-off-by: Chen Gang <gang.chen@asianux.com>
> Applied, thanks.
> 
> 

Thank you, too.


Thanks.
-- 
Chen Gang

Asianux Corporation
