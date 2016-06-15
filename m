From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Tue, 14 Jun 2016 23:40:45 -0700
Message-ID: <20160615064045.GB26911@u54ee753d2d1854bda401.ant.amazon.com>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
 <20160614.222516.1192717052949905017.davem@davemloft.net>
 <20160615062336.GA26911@u54ee753d2d1854bda401.ant.amazon.com>
 <20160614.232709.326751260784989181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netanel@annapurnalabs.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com,
	aliguori@amazon.com, antoine.tenart@free-electrons.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160614.232709.326751260784989181.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 14, 2016 at 11:27:09PM -0700, David Miller wrote:
> From: Matt Wilson <msw@amzn.com>
> Date: Tue, 14 Jun 2016 23:23:36 -0700
> 
> > Point taken, though existing drivers (even fairly popular ones) also
> > aren't as clean as you might like. A quick look around...
> 
> Existing drivers do undesirable things, film at 11...
> 
> Yet are never a reason to accept such things in new drivers.

I generally agree with this philosophy.

> > Like many other network drivers, some of this is common code used for
> > non-Linux systems, and that's why there is some overlap with Linux
> > facilities.
> 
> Again, never an excuse for such things.

I suppose I was just happy to have the *majorly* objectionable parts
cleaned up...

> > Are there other things that jump out at you?
> 
> I review hundreds of patches a day, I invested what I was able to
> before moving on to other people's work.

I wasn't asking you to do more, only if you had anything else you
wanted to say before Netanel sends a v2. 

> Other developers must help review such a large driver submission, it
> can't all be on me.

And I'm certainly not saying it's all on you. I've been reviewing this
with the team for quite a while to get it in pretty reasonable (IMHO)
shape.

--msw
