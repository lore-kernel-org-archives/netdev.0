From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: add CHECKSUM target
Date: Sun, 11 Jul 2010 14:45:49 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007111445320.6015@obet.zrqbmnf.qr>
References: <20100708222913.GA4475@redhat.com> <alpine.LSU.2.01.1007091154120.7235@obet.zrqbmnf.qr> <20100711122708.GA3573@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, herbert.xu@redhat.com, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100711122708.GA3573@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sunday 2010-07-11 14:27, Michael S. Tsirkin wrote:
>> >
>> > include/linux/netfilter_ipv4/ipt_CHECKSUM.h |   18 +++++++
>> > net/ipv4/netfilter/Kconfig                  |   16 ++++++
>> > net/ipv4/netfilter/Makefile                 |    1 +
>> > net/ipv4/netfilter/ipt_CHECKSUM.c           |   72 +++++++++++++++++++++++++++
>> 
>> New modules should use xt.
>
>I tried moving the module to xt_CHECKSUM but now
>	iptables -A POSTROUTING -t mangle -p udp --dport 68 -j CHECKSUM --checksum-fill
>does not to load the module.
>It seems that xt_request_find_target in x_tables uses the prefix 'ip' for a module.
>What am I missing?

MODULE_ALIAS like the others have.
