From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] net: sched: htb: fix condition of failure when rate
 is 0
Date: Thu, 14 Nov 2013 06:37:09 -0800
Message-ID: <1384439829.28458.151.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384419714-24364-1-git-send-email-yangyingliang@huawei.com>
	 <1384419714-24364-3-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:62587 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753293Ab3KNOhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 09:37:11 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so2031141pdi.7
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 06:37:10 -0800 (PST)
In-Reply-To: <1384419714-24364-3-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 17:01 +0800, Yang Yingliang wrote:
> When rate32 is 0, it doesn't means wrong.
> Because htb support 64bit rates now, it
> could use rate64.
> So change the condition, when rate32 and
> rate64 are both 0, it goes to failure.

This is not needed at all and buggy.

User land is supposed to provide a not zero 32bit rate.

If it does, too bad. We have to fail.
