From: Andi Kleen <ak@muc.de>
Subject: Re: System crash in tcp_fragment()
Date: Mon, 20 May 2002 22:29:37 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <acbn1j$otc$2@main.gmane.org>
References: <3CE95190.75C52E2D@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, davem@redhat.com, ak@muc.de,
   kuznet@ms2.inr.ac.ru, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george anzinger <george@mvista.com>
Content-Disposition: inline
In-Reply-To: <3CE95190.75C52E2D@mvista.com>
List-Id: netdev.vger.kernel.org

> Incase you can not see this, it appears that the addresses
> of each skb are alright, so the assumption is that the skb
> passed to tcp_fragment() has been unlinked while
> tcp_fragment() was doing its thing.  This implies a need for
> locking at some higher level and we don't know enough about
> the tcp code to divine where this might best be done.

2.4 TCP should in theory already have enough locking to prevent this
(the socket lock that is aquired by timers and user context socket users) 

-Andi
