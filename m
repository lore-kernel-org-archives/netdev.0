From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 2/3] x_tables: Use also dev->ifalias for interface
 matching
Date: Mon, 12 Jan 2015 17:32:55 +0100 (CET)
Message-ID: <alpine.LSU.2.11.1501121731510.25482@nerf60.vanv.qr>
References: <1421009571-5279-1-git-send-email-richard@nod.at>  <1421009571-5279-3-git-send-email-richard@nod.at> <1421078666.4099.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Richard Weinberger <richard@nod.at>, davem@davemloft.net,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com, john.fastabend@gmail.com,
	herbert@gondor.apana.org.au, vyasevic@redhat.com, jiri@resnulli.us,
	vfalico@gmail.com, therbert@google.com, edumazet@google.com,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org,
	kay@vrfy.org, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421078666.4099.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2015-01-12 17:04, Eric Dumazet wrote:
>
>iptables should have used ifindex [for interface matching],
>it[']s sad we allowed the substring match in first place.

How would you solve interface name wildcards with ifindices?
(They come in handy if you have something like lots of tun+/veth+
interfaces from openvpn/lxc.)
