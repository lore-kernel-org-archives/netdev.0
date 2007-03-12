From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [REVISED] net/ipv4/multipath_wrandom.c: check
 kmalloc() return value.
Date: Mon, 12 Mar 2007 13:56:13 -0700 (PDT)
Message-ID: <20070312.135613.78710501.davem@davemloft.net>
References: <Pine.LNX.4.64.0703121411170.13933@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit2030@gmail.com, linux-kernel@vger.kernel.org, akpm@osdl.org,
	netdev@vger.kernel.org
To: penberg@cs.helsinki.fi
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752923AbXCLU4S@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0703121411170.13933@sbz-30.cs.Helsinki.FI>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pekka J Enberg <penberg@cs.helsinki.fi>
Date: Mon, 12 Mar 2007 14:15:16 +0200 (EET)

> On 3/9/07, David Miller <davem@davemloft.net> wrote:
> > The whole cahce-multipath subsystem has to have it's guts revamped for
> > proper error handling.
> 
> (Untested patch follows.)

I'm not accepting untested patches, if people want to fix this
code it cannot be done in a shoddy manner any more, it will
need to be fixed and tested by people who really care about
this code.

We need real care for this code or I will remove it in 2.6.23
