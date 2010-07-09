From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: add CHECKSUM target
Date: Fri, 9 Jul 2010 18:26:34 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007091824520.1835@obet.zrqbmnf.qr>
References: <20100708222913.GA4475@redhat.com> <4C373D90.8070000@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, herbert.xu@redhat.com, kvm@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C373D90.8070000@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2010-07-09 17:17, Patrick McHardy wrote:
>
>> This adds a `CHECKSUM' target, which can be used in the iptables mangle
>> table.
>> 
>> You can use this target to compute and fill in the checksum in
>> an IP packet that lacks a checksum.  This is particularly useful,
>> if you need to work around old applications such as dhcp clients,
>> that do not work well with checksum offloads, but don't want to
>> disable checksum offload in your device.
>
>I'm not sure this is something we want to merge upstream and
>support indefinitely.

We could put it into Xtables-addons. That would also be consistent
with Dave's suggestion.

>Dave suggested this as a temporary
>out-of-tree workaround until the majority of guest dhcp clients
>are fixed. Has anything changed that makes this course of
>action impractical?
