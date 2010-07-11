From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] netfilter: add CHECKSUM target
Date: Sun, 11 Jul 2010 16:19:15 +0300
Message-ID: <20100711131914.GA3461@redhat.com>
References: <20100708222913.GA4475@redhat.com>
 <alpine.LSU.2.01.1007091154120.7235@obet.zrqbmnf.qr>
 <20100711122708.GA3573@redhat.com>
 <alpine.LSU.2.01.1007111445320.6015@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, herbert.xu@redhat.com, kvm@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.01.1007111445320.6015@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 11, 2010 at 02:45:49PM +0200, Jan Engelhardt wrote:
> 
> On Sunday 2010-07-11 14:27, Michael S. Tsirkin wrote:
> >> >
> >> > include/linux/netfilter_ipv4/ipt_CHECKSUM.h |   18 +++++++
> >> > net/ipv4/netfilter/Kconfig                  |   16 ++++++
> >> > net/ipv4/netfilter/Makefile                 |    1 +
> >> > net/ipv4/netfilter/ipt_CHECKSUM.c           |   72 +++++++++++++++++++++++++++
> >> 
> >> New modules should use xt.
> >
> >I tried moving the module to xt_CHECKSUM but now
> >	iptables -A POSTROUTING -t mangle -p udp --dport 68 -j CHECKSUM --checksum-fill
> >does not to load the module.
> >It seems that xt_request_find_target in x_tables uses the prefix 'ip' for a module.
> >What am I missing?
> 
> MODULE_ALIAS like the others have.

Worked for me, thanks!
