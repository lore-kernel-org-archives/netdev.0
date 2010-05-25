From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH RFC] netfilter: iptables target SYNPROXY
Date: Tue, 25 May 2010 21:03:06 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1005252100500.21791@blackhole.kfki.hu>
References: <1274771218-3204-1-git-send-email-xiaosuo@gmail.com>  <alpine.DEB.2.00.1005251353370.20667@blackhole.kfki.hu> <AANLkTilbZ4PE7c6pep4bYvAx7ydx78qb4tKJi0vCjD52@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTilbZ4PE7c6pep4bYvAx7ydx78qb4tKJi0vCjD52@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, 25 May 2010, Changli Gao wrote:

> On Tue, May 25, 2010 at 8:17 PM, Jozsef Kadlecsik
> <kadlec@blackhole.kfki.hu> wrote:
>
> > On Tue, 25 May 2010, Changli Gao wrote:
> >
> >> iptables target SYNPROXY.
> >>
> >> This patch implements an iptables target SYNPROXY, which works in the raw table
> >> of the PREROUTING chain, before conntracking system. Syncookies is used, so no
> >> new state is introduced into the conntracking system. In fact, until the first
> >> connection is established, conntracking system doesn't see any packets. So when
> >> there is a SYN-flood attack, conntracking system won't be busy on finding and
> >> deleting the un-assured ct.
> >
> > My main problem with your target is that by using it, important and useful
> > TCP options are lost: timestamp and SACK. That pushes back TCP by almost
> > twenty years.
> 
> Yea. Only MSS option is  supported. But it is better than being DoSed.
> And you can set a threshold for SYNPROXY with limit match, then there
> isn't any difference if there isn't any SYN-flood attack.

If I (have to) limit SYNPROXY, why shouldn't I better limit the SYN 
packets directly instead?

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
