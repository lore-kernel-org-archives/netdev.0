From: "David S. Miller" <davem@davemloft.net>
Subject: Re: ipw2100: firmware problem
Date: Wed, 08 Jun 2005 12:43:32 -0700 (PDT)
Message-ID: <20050608.124332.85408883.davem@davemloft.net>
References: <20050608142310.GA2339@elf.ucw.cz>
	<200506081744.20687.vda@ilport.com.ua>
	<42A7268D.9020402@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vda@ilport.com.ua, pavel@ucw.cz, jgarzik@pobox.com, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, ipw2100-admin@linux.intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jketreno@linux.intel.com
In-Reply-To: <42A7268D.9020402@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: James Ketrenos <jketreno@linux.intel.com>
Date: Wed, 08 Jun 2005 12:10:37 -0500

> My approach is to make the driver so it supports as many usage models as
> possible, leaving policy to other components of the system.

I don't see how this kind of firmware load setup handles something
like an NFS root over such a device that requires firmware.

And let's not mention that I have to setup an initrd to make that
work, that's rediculious.

This is the kind of crap that happens when drivers in the kernel
are not self contained, and need "external stuff" to work properly.
It means that simple things like NFS root over the device do not
work in a straightforward, simple, and elegant manner.

I am likely to always take the position that device firmware
belongs in the kernel proper, not via these userland and filesystem
loading mechanism, none of which may be even _available_ when
we first need to get the device going.
