From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 00/18] netfilter updates for net-next
Date: Mon, 29 Apr 2013 22:27:04 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1304292223250.19445@blackhole.kfki.hu>
References: <1367089103-8394-1-git-send-email-pablo@netfilter.org> <20130429.113720.1954422885523724201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130429.113720.1954422885523724201.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Apr 2013, David Miller wrote:

> This doesn't compile:
> 
> net/sched/em_ipset.c:86:5: error: ?struct ip_set_adt_opt? has no member named ?timeout?
> N?????r??y????b?X????v?^?)??{.n?+???z?????u???)????w*jg??????????j/???z?????2???????&?)???a???????G???h????j:+v???w??????

Sorry, that was my fault: I had net sched disabled for faster compilation 
and thus I missed that em_ipset.c had to be adapted to the changes in the 
ipset core.

And Pablo was faster than me - thanks for taking care this too.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
