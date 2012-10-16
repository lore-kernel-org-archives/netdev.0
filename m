From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ipv6: addrconf: fix /proc/net/if_inet6
Date: Tue, 16 Oct 2012 15:01:21 -0700
Message-ID: <1350424881.3072.17.camel@joe-AO722>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	 <1350242941.21172.17023.camel@edumazet-glaptop>
	 <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	 <1350244485.21172.17077.camel@edumazet-glaptop>
	 <CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
	 <1350246314.21172.17139.camel@edumazet-glaptop>
	 <1350246414.21172.17144.camel@edumazet-glaptop>
	 <1350246481.21172.17147.camel@edumazet-glaptop>
	 <CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
	 <1350248858.21172.17197.camel@edumazet-glaptop>
	 <CAO_aot6w9yaWacK9kE66m+Lv0LWXY9hKzLH8b=1dp=23fo_W2A@mail.gmail.com>
	 <1350250542.21172.17229.camel@edumazet-glaptop>
	 <CAO_aot4RiTbUd=7L5e4btLEeJvgy0B3iswaXo8m3AP2qp9Z0TQ@mail.gmail.com>
	 <1350252091.21172.17257.camel@edumazet-glaptop>
	 <CAO_aot6j2TPe9yxnA1ktMQsfnnWF1XwmCrQUmCcfOqCqbc6dZA@mail.gmail.com>
	 <1350279753.21172.17290.camel@edumazet-glaptop>
	 <1350285275.22442.17.camel@joe-AO722>
	 <1350286790.21172.17414.camel@edumazet-glaptop>
	 <1350300302.22442.25.camel@joe-AO722>
	 <1350304308.3954.66.camel@edumazet-glaptop>
	 <CAO_aot59XNERsb7q9pZSpSzyFLv=pKEk6wb82PE-sNMf4TDXow@mail.gmail.com>
	 <1350307293.3954.119.camel@edumazet-glaptop>
	 <CAO_aot44shT8CKtCi8Zv0GWN7wjybHX+d5SFQ1daVOh84v+L1g@mail.gmail.com>
	 <CAO_aot66K-7Je8dSnYTxxkoaDgQ3JpG7t=MdTK0A0ixPX_AP-A@mail.gmail.com>
	 <1350405787.3954.1229.camel@edumazet-glaptop>
	 <1350406522.3954.1242.camel@edumazet-glaptop>
	 <1350409047.3954.1295.camel@edumazet-glaptop>
	 <CAO_aot45DY4A-uM-O1udZUh9XDKJxszgD7w+iVpJw_qcivEeMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Mihai Maruseac <mihai.maruseac@gmail.com>
To: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:35804 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753938Ab2JPWBW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2012 18:01:22 -0400
In-Reply-To: <CAO_aot45DY4A-uM-O1udZUh9XDKJxszgD7w+iVpJw_qcivEeMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-16 at 20:30 +0200, Jan Hinnerk Stosch wrote:
> 2012/10/16 Eric Dumazet <eric.dumazet@gmail.com>:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Commit 1d5783030a1 (ipv6/addrconf: speedup /proc/net/if_inet6 filling)
> > added bugs hiding some devices from if_inet6 and breaking applications.
> >
> > "ip -6 addr" could still display all IPv6 addresses, while "ifconfig -a"
> > couldnt.

Thanks Eric and Jan.  Well done.
