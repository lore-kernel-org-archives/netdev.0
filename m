From: jamal <hadi@cyberus.ca>
Subject: RE: [Bonding-devel] Re: [bonding] Add basic support for dynamic
	configuration of bond interfaces
Date: 13 Jan 2004 09:17:20 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1074003440.1037.429.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0401122032480.6491-100000@humbolt.us.dell.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Feldman, Scott" <scott.feldman@intel.com>,
        Jeff Garzik <jgarzik@pobox.com>, "Noam, Amir" <amir.noam@intel.com>,
        Jay Vosburgh <fubar@us.ibm.com>, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Domsch <Matt_Domsch@dell.com>
In-Reply-To: <Pine.LNX.4.44.0401122032480.6491-100000@humbolt.us.dell.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I think this would be fine if you have some simple policy
maybe upto 5 variables. Its simplicty gives it a lot of value.
However, once you start getting into more demanding setups with lotsa
table based configs this is quickly going to turn into a configuration
nightmare. What we should shoot for with netlink is to make it
as stoopid-proof as well - although not too stoopid proof to be
dangerous.  

cheers,
jamal

On Mon, 2004-01-12 at 21:34, Matt Domsch wrote:
> > Could sysfs be used for the bonding UI?  Seems like a natural fit.
> > Something like:
> > # echo "some params" >/sys/class/net/add_bond
> > # echo "byebye" >/sys/class/net/bond0/del_bond
> 
> FWIW, this is exactly what we're doing with the efivars module to create 
> and destroy EFI Variables now, and appears to be a sane approach.
> 
> Thanks,
> Matt
