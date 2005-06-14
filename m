From: Andi Kleen <ak@muc.de>
Subject: Re: udp.c
Date: 14 Jun 2005 02:12:49 +0200
Message-ID: <20050614001249.GF86745@muc.de>
References: <20050613230422.GA7269@gondor.apana.org.au> <20050613.162052.41635836.davem@davemloft.net> <m1fyvlbyp7.fsf@muc.de> <20050613.170045.74749212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesper.juhl@gmail.com, mru@inprovide.com, rommer@active.by,
	bernd@firmix.at, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261502AbVFNAWX@vger.kernel.org>
Date: Tue, 14 Jun 2005 02:12:49 +0200
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050613.170045.74749212.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2005 at 05:00:45PM -0700, David S. Miller wrote:
> From: Andi Kleen <ak@muc.de>
> Date: Tue, 14 Jun 2005 01:53:56 +0200
> 
> > Still does, as does x86-64, but actually it could be changed now using
> > change_page_attr (and then later undoing it). Is it worth it?
> 
> A lot of bootup OOPS's have occured in the past and
> were never discovered until someone on a non-x86
> platform tested the patch.

Ok I can fix it, but only reasonably after mem_init (at least without
hacking up change_page_attr a lot to deal with bootmem).
Is that still worth it? 

-Andi
