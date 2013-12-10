From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net v7 0/2] net: sched: fix two issues
Date: Tue, 10 Dec 2013 13:47:35 +0800
Message-ID: <52A6AAF7.8080303@huawei.com>
References: <1386647358-47944-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<brouer@redhat.com>, <jpirko@redhat.com>, <jbrouer@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:54027 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748Ab3LJFrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 00:47:43 -0500
In-Reply-To: <1386647358-47944-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/10 11:49, Yang Yingliang wrote:
> fix calculation of max_size in tbf
> fix quantum calculation introduced by 64bit rates.
> 
> v7
>   patch 1/2:
>   1.Set member of "struct tbf_sched_data *q" after calculating
>   max_size successfully, or it will change the old settings while
>   calculating failed.
>   2.If time_in_ns is bigger than ~0U(about 4 sec), it's useless,
>   use ~0U instead.
> 

There is a mistake, ignore this set, sorry for noise.
