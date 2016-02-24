From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] nfc: use GFP_USER for user-controlled kmalloc
Date: Wed, 24 Feb 2016 13:45:21 -0500 (EST)
Message-ID: <20160224.134521.961009575129127582.davem@davemloft.net>
References: <1454095465-16685-1-git-send-email-xiyou.wangcong@gmail.com>
	<CAM_iQpX3X6YoFeMw2KYjJM8yBHi9=3iapo0+a9Cqtc0cxM_QNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com,
	linux-wireless@vger.kernel.org, julian.calaby@gmail.com,
	eric.dumazet@gmail.com, lauro.venancio@openbossa.org,
	aloisio.almeida@openbossa.org, sameo@linux.intel.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753192AbcBXSpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 13:45:24 -0500
In-Reply-To: <CAM_iQpX3X6YoFeMw2KYjJM8yBHi9=3iapo0+a9Cqtc0cxM_QNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 24 Feb 2016 10:41:29 -0800

> On Fri, Jan 29, 2016 at 11:24 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> These two functions are called in sendmsg path, and the
>> 'len' is passed from user-space, so we should not allow
>> malicious users to OOM kernel on purpose.
>>
>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>> Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
>> Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
>> Cc: Samuel Ortiz <sameo@linux.intel.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> Ping...
> 
> David, this patch seems still not applied, I guess you expect NFC
> maintainer to take it, but this doesn't happen. Could you take it?

The NFC maintainer needs to take this, ping them explicitly if
you have to.

Thanks.
