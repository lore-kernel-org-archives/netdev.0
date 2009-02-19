From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: problem with IPoA (CLIP),  NAT, and VLANS
Date: Thu, 19 Feb 2009 07:30:55 +0000
Message-ID: <20090219073055.GA4564@ff.dom.local>
References: <20090218210507.GA2698@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Karl Hiramoto <karl@hiramoto.org>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090218210507.GA2698@ami.dom.local>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18-02-2009 22:05, Jarek Poplawski wrote:
...
> depending on your config or even size of packets. So I guess, knowing
> this all, you should better try to hack this driver more yet.

...And the first step could be trying skb_copy() in the driver's
->hard_start_xmit() callback (of course, if you prefer data safety
over perfomance).

Jarek P.
