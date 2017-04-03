From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: KASAN, xt_TCPMSS  finally found nasty use-after-free bug? 4.10.8
Date: Mon, 03 Apr 2017 05:09:03 -0700
Message-ID: <1491221343.10124.16.camel@edumazet-glaptop3.roam.corp.google.com>
References: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
         <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170402114545.GA31804@breakpoint.cc>
         <1491134084.10124.6.camel@edumazet-glaptop3.roam.corp.google.com>
         <1491135593.10124.9.camel@edumazet-glaptop3.roam.corp.google.com>
         <4442718191e17f0ff91bf1359da6d631@nuclearcat.com>
         <1491136344.10124.10.camel@edumazet-glaptop3.roam.corp.google.com>
         <f005315a672d82fae34f932f4a7f3d5f@nuclearcat.com>
         <1491153268.10124.12.camel@edumazet-glaptop3.roam.corp.google.com>
         <1491153972.10124.14.camel@edumazet-glaptop3.roam.corp.google.com>
         <35bef48734458fd995d9d4080da5db22@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, netdev-owner@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <35bef48734458fd995d9d4080da5db22@nuclearcat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-04-03 at 11:10 +0300, Denys Fedoryshchenko wrote:

> I modified patch a little as:
> if (th->doff * 4 < sizeof(_tcph)) {
>   par->hotdrop = true;
>   WARN_ON_ONCE(!tcpinfo->option);
>   return false;
> }
> 
> And it did triggered WARN once at morning, and didn't hit KASAN. I will 
> run for a while more, to see if it is ok, and then if stable, will try 
> to enable SFQ again.

Excellent news !
We will post an official fix today, thanks a lot for this detective work
Denys.


