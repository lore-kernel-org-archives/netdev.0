From: Amir Noam <amir.noam@intel.com>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond interfaces
Date: Wed, 14 Jan 2004 17:00:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401141700.50119.amir.noam@intel.com>
References: <E6F7D288B394A64585E67497E5126BA601F991D3@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <E6F7D288B394A64585E67497E5126BA601F991D3@hasmsx403.iil.intel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 11 January 2004 11:59 pm, Jeff Garzik wrote:

> ioctls are a pain for 32/64-bit emulation layers too.  It seems
> much easier to define a netlink protocol family of some sort and
> communicate that way.

It seems that a lot of different suggestions were made so far about 
the best way to pass messages unrelated to a specific interface to 
the kernel (char device, netlink, sysfs), all with their own 
advantages and disadvantages.

Until the preferred method is decided on for 2.6, is there a real 
objection to using a generic socket ioctl for bonding in the *2.4* 
kernel? (again, given that several other modules already use such a 
scheme, and won't change that behavior in 2.4)

It would be nice to have the support for dynamically adding/removing 
bonding interfaces in 2.4, and 2.4.25 is about to be the last 2.4 
kernel that accepts new features.

-- 
Amir
