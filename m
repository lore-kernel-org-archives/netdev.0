From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: kenel level packet capturing
Date: Wed, 19 Oct 2011 08:37:33 -0400
Message-ID: <20111019123733.GA21324@synalogic.ca>
References: <CAKj1SsP+GE=QqN8nx7aaAxXE8BODKb=vns_=SnbyySQjZp3-pg@mail.gmail.com>
 <CAKj1SsOnYsOXjRBKm+=hTnEiesXrC3h0Q-KN2b61nPSQud9wMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org
To: raviraj joshi <raviraj.j1991@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAKj1SsOnYsOXjRBKm+=hTnEiesXrC3h0Q-KN2b61nPSQud9wMA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/10/19 12:24, raviraj joshi wrote:
> Hi,
> 
> We are making a kernel level packet capture module as a part of our BE project .
> We are finding it difficult to understand kenel networking code.
> We studied structures and functions like sk_buff, netif_rx(),dev_alloc_skb.
> 
> However we were not able to trace the actual path a simple packet follows.

You might find
http://vger.kernel.org/netconf2011_slides/jesse_brandeburg_netconf2011.pdf
interesting. It contains call chains of UDP processing at all levels in
the stack (driver, below ip stack, above ip stack) for tx and rx.

-Ben
