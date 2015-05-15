From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] netfilter: ipset: deinline ip_set_put_extensions()
Date: Fri, 15 May 2015 22:05:44 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1505152204330.29442@blackhole.kfki.hu>
References: <1430922537-28428-1-git-send-email-dvlasenk@redhat.com> <20150514105605.GA4852@salvia>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp0.kfki.hu ([148.6.0.25]:58275 "EHLO smtp0.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934539AbbEOUFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 16:05:10 -0400
In-Reply-To: <20150514105605.GA4852@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 May 2015, Pablo Neira Ayuso wrote:

> On Wed, May 06, 2015 at 04:28:57PM +0200, Denys Vlasenko wrote:
> > On x86 allyesconfig build:
> > The function compiles to 489 bytes of machine code.
> > It has 25 callsites.
> > 
> >     text    data       bss       dec     hex filename
> > 82441375 22255384 20627456 125324215 7784bb7 vmlinux.before
> > 82434909 22255384 20627456 125317749 7783275 vmlinux
> 
> Jozsef, I'm going to applied this patch to nf-next.

Thanks!

> I think that things like ip_set_put_skbinfo() can be also deinlined
> and move to the core as exported symbol as this run from the control
> plane path (ie. netlink).

I'll add the patch for that to the next round of the ipset patches.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
