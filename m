From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible problem with e6afc8ac ("udp: remove headers from UDP
 packets before queueing")
Date: Thu, 02 Jun 2016 19:58:26 -0700
Message-ID: <1464922706.5939.186.camel@edumazet-glaptop3.roam.corp.google.com>
References: <0b1fde4f-57ef-8c5e-147f-10c4a51fb2b0@tycho.nsa.gov>
	 <CAHC9VhQAiTRWMN-vNDXgAni2MhsyEYP8f2mZDY63xrx=5SxenQ@mail.gmail.com>
	 <1464904363.5939.185.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160602.183151.2030076167275348260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paul@paul-moore.com, samanthakumar@google.com,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, sds@tycho.nsa.gov
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20160602.183151.2030076167275348260.davem@davemloft.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-06-02 at 18:31 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 02 Jun 2016 14:52:43 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Paul Moore tracked a regression caused by a recent commit, which
> > mistakenly assumed that sk_filter() could be avoided if socket
> > had no current BPF filter.
> > 
> > The intent was to avoid udp_lib_checksum_complete() overhead.
> > 
> > But sk_filter() also checks skb_pfmemalloc() and
> > security_sock_rcv_skb(), so better call it.
> > 
> > Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Reported-by: Paul Moore <paul@paul-moore.com>
> > Tested-by: Paul Moore <paul@paul-moore.com>
> > Tested-by: Stephen Smalley <sds@tycho.nsa.gov>
> > Cc: samanthakumar <samanthakumar@google.com>
> 
> Applied, thanks Eric.

Arg, I totally messed up the patch title :(



