From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: sctp: clone options to avoid use after free
Date: Fri, 11 Dec 2015 20:19:16 -0500 (EST)
Message-ID: <20151211.201916.1656429874143124778.davem@davemloft.net>
References: <20151209145917.GA3884@mrl.redhat.com>
	<CANn89iLhetNbtO6h99zZOrCiMYON50vzVsk7j_AtosXejvvm4Q@mail.gmail.com>
	<1449674706.9768.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, marcelo.leitner@gmail.com, dvyukov@google.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vyasevich@gmail.com,
	nhorman@tuxdriver.com, linux-sctp@vger.kernel.org,
	syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
	sasha.levin@oracle.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449674706.9768.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Dec 2015 07:25:06 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> SCTP is lacking proper np->opt cloning at accept() time.
> 
> TCP and DCCP use ipv6_dup_options() helper, do the same
> in SCTP.
> 
> We might later factorize this code in a common helper to avoid
> future mistakes.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
