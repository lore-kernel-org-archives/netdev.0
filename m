From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: extended netdevice naming proposal
Date: Thu, 18 Nov 2010 02:29:57 +0000
Message-ID: <1290047397.3818.3.camel@localhost>
References: <20101117220659.GA12177@auslistsprd01.us.dell.com>
	 <20101118021039.GA18707@nostromo.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matt Domsch <Matt_Domsch@dell.com>, linux-hotplug@vger.kernel.org,
	netdev@vger.kernel.org, narendra_k@dell.com, jcm@redhat.com
To: Bill Nottingham <notting@redhat.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20101118021039.GA18707@nostromo.devel.redhat.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-11-17 at 21:10 -0500, Bill Nottingham wrote:
> Matt Domsch (Matt_Domsch@dell.com) said: 
> > (location)(slot)#(port)/(instance).(vlan)
> 
> AIUI, the kernel explicitly rejects '/' in the name (for fairly obvious
> sysfs reasons.) So you'd at least need a different delimiter. There may
> also be potential confusion with pci01#03:02.0001 with someone thinking
> that's bus/dev/fn, if we're being really petty.

':' is also reserved for alias interfaces, the old way of assigning
multiple IP addresses.

I would say '-' is a good separator, but that might result in ambiguity
in IRQ names.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

