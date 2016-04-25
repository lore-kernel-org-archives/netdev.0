From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: linux-next: zillions of lockdep whinges in include/net/sock.h:1408
Date: Mon, 25 Apr 2016 15:26:24 +0200
Message-ID: <1461590784.1178151.588791921.6E503291@webmail.messagingengine.com>
References: <43037.1461229555@turing-police.cc.vt.edu>
 <1461245496.7627.17.camel@edumazet-glaptop3.roam.corp.google.com>
 <5718DA71.7050902@stressinduktion.org>
 <20160424.143833.2292980084570149367.davem@davemloft.net>
 <571D14F8.6070306@stressinduktion.org>
 <1461527202.5535.1.camel@edumazet-glaptop3.roam.corp.google.com>
 <176911.1461527778@turing-police.cc.vt.edu>
 <1461531617.5535.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <181815.1461532395@turing-police.cc.vt.edu>
 <1461533101.5535.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>, Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461533101.5535.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 24, 2016, at 23:25, Eric Dumazet wrote:
>  #ifdef CONFIG_LOCKDEP
> -       WARN_ON(!lockdep_sock_is_held(sk));
> +       WARN_ON_ONCE(!lockdep_sock_is_held(sk) && !debug_locks);
>  #endif

Eric, could you resend this patch without the negation and also add my
acked-by (I came finally around to test it).

Thanks,
Hannes
