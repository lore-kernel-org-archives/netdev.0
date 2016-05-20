From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 1/3] netfilter: ipset: use setup_timer() and
 mod_timer().
Date: Fri, 20 May 2016 22:40:47 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1605202238420.16031@blackhole.kfki.hu>
References: <1463173145-16167-1-git-send-email-falakreyaz@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Vishwanath Pai <vpai@akamai.com>,
	Joshua Hunt <johunt@akamai.com>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Muhammad Falak R Wani <falakreyaz@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1463173145-16167-1-git-send-email-falakreyaz@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 14 May 2016, Muhammad Falak R Wani wrote:

> Use setup_timer() and instead of init_timer(), being the preferred way
> of setting up a timer.
> 
> Also, quoting the mod_timer() function comment:
> -> mod_timer() is a more efficient way to update the expire field of an
>    active timer (if the timer is inactive it will be activated).
> 
> Use setup_timer() and mod_timer() to setup and arm a timer, making the
> code compact and easier to read.
> 
> Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>
> ---
>  net/netfilter/ipset/ip_set_bitmap_gen.h | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)

The patch and the other too in the series as well are applied in the ipset 
git repository and will be submitted for kernel inclusion. Thanks.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
