From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] Expose netdevice dev_id through sysfs
Date: Sun, 20 Apr 2008 12:12:46 +0100
Message-ID: <1208689966.9212.428.camel@pmac.infradead.org>
References: <1208176322.31695.73.camel@pmac.infradead.org>
	 <20080419.183341.46125500.davem@davemloft.net>
	 <1208688644.9212.407.camel@pmac.infradead.org>
	 <20080420.035515.12616544.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, md@linux.it, harald@redhat.com,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20080420.035515.12616544.davem@davemloft.net>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2008-04-20 at 03:55 -0700, David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Sun, 20 Apr 2008 11:50:44 +0100
> 
> > Certainly, it's possible that we'll need _more_ criteria for udev to
> > match on; that doesn't necessarily mean that dev_id shouldn't be one of
> > them, does it?
> 
> I've read what you have to say, and your point is logical.
> 
> However you've just also stated that dev_id isn't even needed to solve
> the particular problems you're interested in.

This is true (assuming udev gets fixed). 

> I'm not against exporting the value.  But let's do it because it does
> solve a problem, not because it's fun to export every object instance
> variable via sysfs :-)

The reason I still submitted it, after realising that Marco's objections
to letting udev rely on the 'KERNEL==' match were bogus, is because I
think it does still help on S390 -- it lets us remove the special case
hack there.

I don't think it's actually _broken_ on S390 at the moment; just a bit
icky. That was sufficient motivation to still submit the patch :)

-- 
dwmw2

