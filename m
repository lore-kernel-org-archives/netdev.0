From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Tue, 15 Oct 2013 17:39:09 -0700
Message-ID: <1381883949.2045.97.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au>
	 <1381882426.2045.85.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131016002807.GM22321@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>,
	Mark Brooks <mark@loadbalancer.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131016002807.GM22321@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-10-16 at 09:28 +0900, Simon Horman wrote:

> > I guess things like NFQUEUE could happen ?
> 
> Could you expand a little?

This was to point that between IPVS and ipv6 stack we might have a
delay, and daddr was maybe pointed to a freed memory.

IP6CB only uses 24 bytes, so I think you would be safe adding 16 bytes.



