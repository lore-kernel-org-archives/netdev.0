From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 4/4] ipv4: Namespaceify
 tcp_fastopen_blackhole_timeout knob
Date: Thu, 28 Sep 2017 10:48:01 -0700 (PDT)
Message-ID: <20170928.104801.364432233895912663.davem@davemloft.net>
References: <1506483343-11544-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
        <1506483343-11544-4-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, edumazet@google.com, weiwan@google.com,
        lucab@debian.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506483343-11544-4-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Wed, 27 Sep 2017 11:35:43 +0800

> Different namespace application might require different time period in
> second to disable Fastopen on active TCP sockets.
> 
> Tested:
> Simulate following similar situation that the server's data gets dropped
> after 3WHS.
> C ---- syn-data ---> S
> C <--- syn/ack ----- S
> C ---- ack --------> S
> S (accept & write)
> C?  X <- data ------ S
> 	[retry and timeout]
> 
> And then print netstat of TCPFastOpenBlackhole, the counter increased as
> expected when the firewall blackhole issue is detected and active TFO is
> disabled.
> # cat /proc/net/netstat | awk '{print $91}'
> TCPFastOpenBlackhole
> 1
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.
