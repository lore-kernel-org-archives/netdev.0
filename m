From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tbf: add 64bit rates support
Date: Mon, 2 Dec 2013 23:52:55 -0800
Message-ID: <20131202235255.3d1fb74f@nehalam.linuxnetplumber.net>
References: <1385430935-19740-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:41011 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818Ab3LCHw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 02:52:59 -0500
Received: by mail-pa0-f49.google.com with SMTP id kx10so2578358pab.36
        for <netdev@vger.kernel.org>; Mon, 02 Dec 2013 23:52:58 -0800 (PST)
In-Reply-To: <1385430935-19740-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Nov 2013 09:55:35 +0800
Yang Yingliang <yangyingliang@huawei.com> wrote:

> tbf support 64bit rates start from linux-3.13.
> Add 64bit rates support in tc tools.
> 
> tc qdisc show dev eth0
> qdisc tbf 1: root refcnt 2 rate 40000Mbit burst 230000b peakrate 50000Mbit minburst 87500b lat 50.0ms
> 
> This is a followup to ("htb: support 64bit rates").
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> Cc: Eric Dumazet <edumazet@google.com>

Queued in net-next-for-3.13; since it does not build against 3.13-rc2
