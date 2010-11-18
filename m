From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: extended netdevice naming proposal
Date: Thu, 18 Nov 2010 19:00:49 +0000
Message-ID: <1290106849.2573.11.camel@bwh-desktop>
References: <20101117220659.GA12177@auslistsprd01.us.dell.com>
	 <20101118021039.GA18707@nostromo.devel.redhat.com>
	 <1290047397.3818.3.camel@localhost>
	 <20101118185125.GA4952@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bill Nottingham <notting@redhat.com>,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	narendra_k@dell.com, jcm@redhat.com
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20101118185125.GA4952@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-11-18 at 12:51 -0600, Matt Domsch wrote:
> On Thu, Nov 18, 2010 at 02:29:57AM +0000, Ben Hutchings wrote:
> > On Wed, 2010-11-17 at 21:10 -0500, Bill Nottingham wrote:
> > > Matt Domsch (Matt_Domsch@dell.com) said: 
> > > > (location)(slot)#(port)/(instance).(vlan)
> > > 
> > > AIUI, the kernel explicitly rejects '/' in the name (for fairly obvious
> > > sysfs reasons.) So you'd at least need a different delimiter. There may
> > > also be potential confusion with pci01#03:02.0001 with someone thinking
> > > that's bus/dev/fn, if we're being really petty.
> > 
> > ':' is also reserved for alias interfaces, the old way of assigning
> > multiple IP addresses.
> > 
> > I would say '-' is a good separator, but that might result in ambiguity
> > in IRQ names.
> 
> How about underscore to separate VFs? 
> (location)(slot)#(port)_(instance).(vlan)

That does seem like the best separator available.

> And 'em' as prefix for embedded?
[...]

That also fits the mnemonic Ethernet on Motherboard, which is nice.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

