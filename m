From: Olivier Galibert <galibert@pobox.com>
Subject: Re: ipw2100: firmware problem
Date: Thu, 9 Jun 2005 23:12:42 +0200
Message-ID: <20050609211242.GA30319@dspnet.fr.eu.org>
References: <20050608142310.GA2339@elf.ucw.cz> <42A723D3.3060001@linux.intel.com> <m1is0nvdkw.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Ketrenos <jketreno@linux.intel.com>, Jeff Garzik <jgarzik@pobox.com>,
        Netdev list <netdev@oss.sgi.com>,
        kernel list <linux-kernel@vger.kernel.org>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <m1is0nvdkw.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 09, 2005 at 03:56:15PM +0200, Andi Kleen wrote:
> I guess at some point we will need a file system in there, but - oops -
> we already have one, dont we? :)

Well, you could put .config in it too.

Frankly, a filesystem that:
- can be somehow linked with vmlinux and not separate like an initrd

- editable post vmlinux-linking

- gives files that can be accessed from request_firmware, acpi and
  friends even rather early in the boot process (i.e. well before any
  userland is allowed to exist)

- accessible post-boot through mounting of a special fs and/or /proc or something

would be quite useful.

  OG.
