From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/2] net: dsa: don't unmask port bitmaps
Date: Thu, 26 Oct 2017 10:43:47 +0200
Message-ID: <20171026084347.GC20299@lunn.ch>
References: <87h8upeesg.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <be302ef8-7f12-aaf1-5f68-c4de89c7d83d@gmail.com>
 <20171024092234.GA2911@lunn.ch>
 <20171026.170618.1949112293231201383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171026.170618.1949112293231201383.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > I just think there might be potential for regressions here. But i've
> > not yet looked at the details to really know if there actually is.
> 
> I realize there is still some trepidation about these patches, but it
> seems like the only real way to find out if it causes regressions is
> to apply them and watch carefully.
> 
> So I've applied this and if anything pops up we can easily revert.

Hi David

Yes, this is good. I will try to test this next week with the platform
i had issues with. We are only going to hit problems with D in DSA
platforms, and there are not many of them. So even if it is broken, it
will not affect many people.

	   Andrew
