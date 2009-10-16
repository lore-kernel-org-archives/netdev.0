From: dann frazier <dannf@hp.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 16 Oct 2009 15:40:24 -0600
Message-ID: <20091016214024.GA10091@ldl.fc.hp.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
 <20091013150839.GD32107@ldl.fc.hp.com>
 <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com>
 <20091013173638.GE1119@ldl.fc.hp.com>
 <20091016003245.GD29672@ldl.fc.hp.com>
 <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com>
 <20091016152053.GA9862@ldl.fc.hp.com>
 <1255707193.2869.12.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra_K@Dell.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, Matt_Domsch@Dell.com,
	Jordan_Hargrave@Dell.com, Charles_Rose@Dell.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1255707193.2869.12.camel@achroite>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 16, 2009 at 04:33:13PM +0100, Ben Hutchings wrote:
> On Fri, 2009-10-16 at 09:20 -0600, dann frazier wrote:
> > On Fri, Oct 16, 2009 at 07:32:50PM +0530, Narendra_K@Dell.com wrote:
> [...]
> > > And how would the regular file look like in terms of holding ifindex of
> > > the interface, which can be passed to libnetdevname.
> > 
> > I can't think of anything we need to store in the regular file. If we
> > have the kernel name for the device, we can look up the ifindex in
> > /sys. Correct me if I'm wrong, but storing it ourselves seems
> > redundant.
> 
> But the name of a netdev can change whereas its ifindex never does.
> Identifying netdevs by name would require additional work to update the
> links when a netdev is renamed and would still be prone to race
> conditions.  This is why Narendra and Matt were proposing to store the
> ifindex in the node all along...

Matt, Ben and I talked about a few other possibilities on IRC.
The one I like the most at the moment is an idea Ben had to creat
dummy files named after the ifindex. Then, use symlinks for the kernel
name and the various by-$property subdirectories. This means the KOBJ
events will need to expose the ifindex.

I'm a novice at net programming, but I'm told that ifindex is
the information apps ultimately require here.

-- 
dann frazier

