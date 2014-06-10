From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [patch net-next 3/5] ipv6: consider net.ipv6.conf.all sysctls
 when making decisions
Date: Tue, 10 Jun 2014 19:15:46 +0200
Message-ID: <53973D42.4010209@enst-bretagne.fr>
References: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com> <1402417153-2551-4-git-send-email-milos.vyletel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	stephen hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	"open list:USB CDC ETHERNET..." <linux-usb@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Milos Vyletel <milos.vyletel@gmail.com>, davem@davemloft.net,
	amwang@redhat.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402417153-2551-4-git-send-email-milos.vyletel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

> 
> IN6_DEV_MAXCONF
> 	IN6_DEV_HOPLIMIT
> 	IN6_DEV_MTU

I'm a little bit surprise to set the MTU as the maximum of all/dev
value. Since the default for "all" is IPV6_MIN_MTU, it is probably
harmless, but it could be a little bit surprising for administrators.

>  IN6_DEV_USE_TEMPADDR

For this one, the default is zero, except for point-to-point and
loopback, with -1. I didn't see any difference between 0 and -1 in the
current kernel code, but if I missed something, it could be a little
problem.
