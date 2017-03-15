From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next 4/5] sunvnet: count multicast packets
Date: Wed, 15 Mar 2017 08:50:05 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB12CF@AcuExch.aculab.com>
References: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
 <1489512283-422140-5-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Shannon Nelson' <shannon.nelson@oracle.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489512283-422140-5-git-send-email-shannon.nelson@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson
> Sent: 14 March 2017 17:25
...
> +	if (unlikely(is_multicast_ether_addr(eth_hdr(skb)->h_dest)))
> +		dev->stats.multicast++;

I'd guess that:
	dev->stats.multicast += is_multicast_ether_addr(eth_hdr(skb)->h_dest);
generates faster code.
Especially if is_multicast_ether_addr(x) is (*x >> 7).

	David
