From: Andi Kleen <ak@muc.de>
Subject: Re: Network oops
Date: Sat, 22 Jun 2002 02:55:51 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <af0inl$uun$2@main.gmane.org>
References: <20020609.213150.32126725.davem@redhat.com> <3D042F8F.72764243@mvista.com> <3D120EAE.5A0D365E@mvista.com> <20020620.173805.55219901.davem@redhat.com> <3D133538.60B6810C@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, ak@muc.de, pekkas@netcore.fi,
   andrew.r.cress@intel.com
Return-path: <owner-netdev@oss.sgi.com>
To: george anzinger <george@mvista.com>
Content-Disposition: inline
In-Reply-To: <3D133538.60B6810C@mvista.com>
List-Id: netdev.vger.kernel.org

> > It requires a full audit of the networking in the new preemption
> > environment.
> 
> Any pointers on what to look for would be welcome.

I would look at the driver, especially races in its skb handling.

-Andi
