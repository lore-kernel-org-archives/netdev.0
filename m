From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/3] ipv4: Namespaceify tcp_fastopen_key knob
Date: Mon, 25 Sep 2017 16:24:45 -0700 (PDT)
Message-ID: <20170925.162445.234890912211240693.davem@davemloft.net>
References: <1506088124-12650-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
        <1506088124-12650-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, edumazet@google.com, weiwan@google.com,
        lucab@debian.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506088124-12650-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Fri, 22 Sep 2017 21:48:43 +0800

> @@ -9,13 +9,18 @@
>  #include <net/inetpeer.h>
>  #include <net/tcp.h>
>  
> -struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
> -
> -static DEFINE_SPINLOCK(tcp_fastopen_ctx_lock);
> -
> -void tcp_fastopen_init_key_once(bool publish)
> +void tcp_fastopen_init_key_once(struct net *net)

Why did you remove the 'publish' logic from this function?
