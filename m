From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] sock_diag: do not disclose sock ptr to
 all users
Date: Thu, 25 Apr 2013 09:57:02 -0700
Message-ID: <1366909022.8964.166.camel@edumazet-glaptop>
References: <20130425.050008.2129680886418162075.davem@davemloft.net>
	  <1366896111-4436-1-git-send-email-nicolas.dichtel@6wind.com>
	  <1366896111-4436-4-git-send-email-nicolas.dichtel@6wind.com>
	  <1366903930.8964.154.camel@edumazet-glaptop>
	 <1366904177.8964.155.camel@edumazet-glaptop> <51795D95.9090904@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:53358 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932182Ab3DYQ5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 12:57:08 -0400
Received: by mail-pd0-f173.google.com with SMTP id v14so593794pde.4
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 09:57:06 -0700 (PDT)
In-Reply-To: <51795D95.9090904@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 18:45 +0200, Nicolas Dichtel wrote:

> I definitely miss the thread about this topic, I will try to find it.

If you think about it, what can possibly the issues ?

Generating a true unique cookie will add a contention point in socket
creation/deletion. [ using an atomic64_t , or idr ]

One possibility was to XOR using a private random (chosen at boot time)
value, but this might be not enough for security guys.

At that time, I decided I was not spending time on this issue.

If you want to do it, make sure you don't respin old stuff and don't
remove existing functionality. Our review time is limited.

Thanks
