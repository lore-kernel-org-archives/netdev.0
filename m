From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [2.6 patch] fix ipvs compilation
Date: Thu, 5 Jan 2006 12:21:39 -0200
Message-ID: <39e6f6c70601050621l1a63d061pd91e90035bf79873@mail.gmail.com>
References: <20060105135943.GA3831@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751278AbWAEOVl@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060105135943.GA3831@stusta.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/5/06, Adrian Bunk <bunk@stusta.de> wrote:
> I don't know which change broke it, but I'm getting the following
> compile error in Linus' tree:
>
> <--  snip  -->
>
> ...
>   CC      net/ipv4/ipvs/ip_vs_sched.o
> net/ipv4/ipvs/ip_vs_sched.c: In function 'ip_vs_sched_getbyname':
> net/ipv4/ipvs/ip_vs_sched.c:110: warning: implicit declaration of function 'local_bh_disable'
> net/ipv4/ipvs/ip_vs_sched.c:124: warning: implicit declaration of function 'local_bh_enable'

Thanks Adrian, its related to some header sanitization work I did.

Acked-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

- Arnaldo
