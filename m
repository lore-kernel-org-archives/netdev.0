From: Greg KH <greg@kroah.com>
Subject: Re: [Bonding-devel] Re: [PATCH 2.6.13-rc1 8/17] bonding: SYSFS INTERFACE (large)
Date: Fri, 8 Jul 2005 10:24:34 -0700
Message-ID: <20050708172434.GI29606@kroah.com>
References: <31F5998A44B92447BD334F8FBBA0B01F099F2656@orsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "John W. Linville" <linville@tuxdriver.com>,
        "Godse, Radheka" <radheka.godse@intel.com>, netdev@oss.sgi.com,
        bonding-devel@lists.sourceforge.net, fubar@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Content-Disposition: inline
In-Reply-To: <31F5998A44B92447BD334F8FBBA0B01F099F2656@orsmsx401.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 07, 2005 at 05:32:03PM -0700, Brown, Aaron F wrote:
> >Why not just put them in /sys/class/bond/ instead?
> 
> Bonding creates a virtual network device, it seems to logically fit down
> in /sys/class/net much better then at a level all to itself.

Ok, fair enough, it's up to you all where you want to put it, I was just
offering a suggestion.

> >> The problem, then, becomes one of separating the bond interfaces from
> the
> >> non-bond interfaces.
> >
> >See proposal above.
> >
> >> The bonding_masters file is a simple solution to
> >> this problem.  Reading the file gives the set of active bonds, and
> >writing
> >> the file changes the set of active bonds.  As I stated before, a
> cursory
> >> reading of Documentation/filesystems/sysfs.txt indicates that such a
> >usage
> >> is "socially acceptable".  (Or at least it was to Patrick Mochel back
> in
> >> January of 2003.)
> >
> >Pat was just trying to be nice.  I'm not.  :)
> >
> >Also, if you have too many bonds, your code will fail.
> 
> This is true, but an unlikely event in any real system I am aware of.
> If I use the max_bonds load parameter and create say 600 bonds (which
> will be named bond0, bond1... bond599) then cat out the bonding_masters
> file I only see 524 bonds (bond0...bond523.)

Yup, don't want to have that happen.  So I'm glad you agree with me :)

> However, as a bond interface requires at least one but usually more
> physical network devices to be of much benefit I see it unlikely that
> anybody will really ever have a real need for that many bonds.  Since
> bonding really is used for combining 2 or more adapters into a single
> logical channel it could handle 1048 ports set up in bonds of 2 before
> this type of failure would appear.  

Can you guarantee that no one wants that many bonds?  I can't, and I
don't think you want to redo your userinterface some time in the future
when people ask for this.  My proposal has no such limitations.

thanks,

greg k-h
