From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Fri, 30 Nov 2012 15:47:51 -0800
Message-ID: <20121130154751.06f7d3f7@nehalam.linuxnetplumber.net>
References: <20121129161019.17754.29670.stgit@dragon>
	<20121129161052.17754.85017.stgit@dragon>
	<20121129.124427.1093031685966728935.davem@davemloft.net>
	<1354227470.11754.348.camel@localhost>
	<1354230100.3299.40.camel@edumazet-glaptop>
	<1354269846.11754.381.camel@localhost>
	<1354287134.3299.67.camel@edumazet-glaptop>
	<1354290335.11754.447.camel@localhost>
	<1354293469.3299.81.camel@edumazet-glaptop>
	<1354311437.11754.459.camel@localhost>
	<1354314319.20109.179.camel@edumazet-glaptop>
	<1354317815.11754.498.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, pablo@netfilter.org, tgraf@suug.ch,
	amwang@redhat.com, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39053 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755452Ab2K3XtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 18:49:08 -0500
In-Reply-To: <1354317815.11754.498.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My $.02 is that this would be a good place to introduce lock-free auto
resizing hash lists that are in the userspace RCU library.

It would be a non-trivial effort to put this in the kernel, but
it would let the table grow transparently.
