From: Patrick McHardy <kaber@trash.net>
Subject: Re: problem with IPoA (CLIP),  NAT, and VLANS
Date: Tue, 17 Feb 2009 13:28:11 +0100
Message-ID: <499AAD5B.8060706@trash.net>
References: <20090216232016.GA4803@ami.dom.local> <499AA433.8070308@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Karl Hiramoto <karl@hiramoto.org>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <499AA433.8070308@hiramoto.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karl Hiramoto wrote:
> What Patrick,  said may be the case,  that the underlaying atm driver is
> not specifying the headroom.   The driver is ported to 2.6.28 from
> 2.6.11 based on the BSD licensed intel libaries:
> http://www.intel.com/design/network/products/npfamily/download_ixp400.htm

If those are the ones I think they are, I'm not too surprised ...

> Where underneath a bunch of layers the skb is allocated with kmalloc like:
> 
> size = PAGE_ALIGN (size + CACHE_LINE_SIZE);
> order = get_order (size);
> page = alloc_pages (GFP_KERNEL, order);

How does it initialize the netdev struct?

