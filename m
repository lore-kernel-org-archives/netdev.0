From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] IPV6: inappropriate usage of inet{,6}_sk()
Date: Mon, 27 Oct 2003 12:32:56 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031027143256.GE10490@conectiva.com.br>
References: <20031027.232700.97608602.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20031027.232700.97608602.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Mon, Oct 27, 2003 at 11:27:00PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ escreveu:
> Hi,
> 
> I found other inappropriate usages of inet{,6}_sk() for 
> tcp_tw_bucket:
>  - inet6_sk(sk)->ipv6only
>  - inet6_sk(sk)->rcv_saddr
>  - inet_sk(sk)->rcv_saddr
> 
> Patch is against my previous patch.

Great, part of this was in the first patch I send fixing the addrconf stuff,
I should have submitted those before, but went to Europe, etc, thanks
Yoshifuji-san!

- Arnaldo
