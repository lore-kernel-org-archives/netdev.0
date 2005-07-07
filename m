From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 2.6.13-rc1 8/17] bonding: SYSFS INTERFACE (large)
Date: Thu, 7 Jul 2005 10:25:48 -0400
Message-ID: <20050707142544.GA9418@tuxdriver.com>
References: <Pine.LNX.4.61.0507011347060.17459@localhost.localdomain> <20050702081346.GA20789@kroah.com> <Pine.CYG.4.58.0507061138030.1208@mawilli1-desk2.amr.corp.intel.com> <20050706195232.GB18359@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        Radheka Godse <radheka.godse@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg KH <greg@kroah.com>
Content-Disposition: inline
In-Reply-To: <20050706195232.GB18359@kroah.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 06, 2005 at 12:52:32PM -0700, Greg KH wrote:
> On Wed, Jul 06, 2005 at 11:53:13AM -0700, Mitch Williams wrote:

> > scheme.  Since it really is an array of similar values, we are hoping that
> > it will be viewed as socially acceptable.
> 
> No.
> 
> How about this:
> 	bond_add - write to this to add a new bond, one value only.
> 	bond_remove - write to this to remove a bond that is present.
> 	bonds/bond0
> 	bonds/bond1
> 	bonds/bond2
> 	...
> 		- list of bonds currently present.  If you want, you
> 		  could make those bondX files directories, and put
> 		  other info about the individual bonds in there, if you
> 		  need it (I know nothing about the bonding intrerface,
> 		  sorry.)
> 
> Would that work?

I like that suggestion.  It keeps the interface creation/deletion a
little more independent of each other.

John
-- 
John W. Linville
linville@tuxdriver.com
