From: jamal <hadi@cyberus.ca>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond
	interfaces
Date: 11 Jan 2004 13:30:51 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1073845851.1115.297.camel@jzny.localdomain>
References: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com>
	 <200401111628.07930.amir.noam@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Amir Noam <amir.noam@intel.com>
In-Reply-To: <200401111628.07930.amir.noam@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-01-11 at 09:28, Amir Noam wrote:

> 
> > I would suggest a simple character device (misc_register), and let
> > the userland application configure settings unrelated to a single
> > object.
> 
> I was trying to follow the example of several other network modules 
> (e.g. vlan, dlci, bridge) that use a socket level ioctl hook to 
> handle such deviceless commands.
> 
> Do you think that a char device is preferrable, given that other 
> similar modules use a socket ioctl hook?

I think a netlink interface would be the better alternative.
The L2C netlink socket protocol would be appropriate for bonding
at least for 2.6.x. Bridging, VLAN should also move to this.

cheers,
jamal
