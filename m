From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] net: sched: tbf: fix calculation of max_size
Date: Thu, 14 Nov 2013 06:38:30 -0800
Message-ID: <1384439910.28458.152.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384419714-24364-1-git-send-email-yangyingliang@huawei.com>
	 <1384419714-24364-2-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:41522 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361Ab3KNOic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 09:38:32 -0500
Received: by mail-pd0-f173.google.com with SMTP id x10so2065383pdj.18
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 06:38:31 -0800 (PST)
In-Reply-To: <1384419714-24364-2-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 17:01 +0800, Yang Yingliang wrote:
> Current max_size is caluated from rate table.
> Now, the rate table has been replaced and it's
> not proper to caculate max_size with rate64.
> Use psched_ns_t2l to calculate the max_size.
> 
> psched_ns_t2l():convert time in ns to length in
> bytes which to determinate how many bytes can be
> sent in given time.

I have no evidence you fix a real bug.

Please provide a tc script and show us it breaks.

Also CC Jesper you wrote this code.
