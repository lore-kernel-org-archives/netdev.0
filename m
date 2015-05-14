From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: ipset: deinline ip_set_put_extensions()
Date: Thu, 14 May 2015 12:56:05 +0200
Message-ID: <20150514105605.GA4852@salvia>
References: <1430922537-28428-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36326 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932578AbbENKvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2015 06:51:22 -0400
Content-Disposition: inline
In-Reply-To: <1430922537-28428-1-git-send-email-dvlasenk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 06, 2015 at 04:28:57PM +0200, Denys Vlasenko wrote:
> On x86 allyesconfig build:
> The function compiles to 489 bytes of machine code.
> It has 25 callsites.
> 
>     text    data       bss       dec     hex filename
> 82441375 22255384 20627456 125324215 7784bb7 vmlinux.before
> 82434909 22255384 20627456 125317749 7783275 vmlinux

Jozsef, I'm going to applied this patch to nf-next.

I think that things like ip_set_put_skbinfo() can be also deinlined
and move to the core as exported symbol as this run from the control
plane path (ie. netlink).

Thanks.
