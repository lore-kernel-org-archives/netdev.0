From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in netdevice
Date: Tue, 17 May 2011 23:48:21 +0200
Message-ID: <BANLkTimvOK3tyo6+L5AD=so5DjiDPV-AAA@mail.gmail.com>
References: <1305574128.3456.23.camel@localhost.localdomain>
 <1305574518.2885.25.camel@bwh-desktop> <1305574680.3456.33.camel@localhost.localdomain>
 <1305575253.2885.28.camel@bwh-desktop> <20110516211459.GE18148@redhat.com> <1305588738.3456.65.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305588738.3456.65.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/5/17 Shirley Ma <mashirle@us.ibm.com>:
> Hello Michael,
>
> Looks like to use a new flag requires more time/work. I am thinking
> whether we can just use HIGHDMA flag to enable zero-copy in macvtap t=
o
> avoid the new flag for now since mavctap uses real NICs as lower devi=
ce?

Is there any other restriction besides requiring driver to not recycle
the skb? Are there any drivers that recycle TX skbs?

Best Regards,
Micha=B3 Miros=B3aw
