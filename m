From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: Make ipconfig.c work as a loadable module.
Date: Sat, 8 Mar 2003 17:05:32 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030308170532.D1896@flint.arm.linux.org.uk>
References: <Pine.LNX.4.44.0303081132030.12316-100000@kenzo.iwr.uni-heidelberg.de> <m14r6dlu4w.fsf@frodo.biederman.org> <20030308161936.C1896@flint.arm.linux.org.uk> <m1zno5kdnz.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>,
   Chris Dukes <pakrat@www.uk.linux.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
   Jeff Garzik <jgarzik@pobox.com>, Robin Holt <holt@sgi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Content-Disposition: inline
In-Reply-To: <m1zno5kdnz.fsf@frodo.biederman.org>; from ebiederm@xmission.com on Sat, Mar 08, 2003 at 09:48:16AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 08, 2003 at 09:48:16AM -0700, Eric W. Biederman wrote:
> I can change the contents of my ramdisk as easily as I can change
> the kernel command line.  For the complex setups just placing
> a configuration file in the ramdisk is what seems to work the best
> in practice.

You'll forgive me if I don't think that "change the contents of ramdisk"
is as easy as changing the kernel command line.

Last time I checked, to change the contents of a ramdisk image, you needed
to ungzip it, mount it, make some changes, unmount it, re-gzip it, and
re-install the thing.  Or, in the case of initramfs, you need to rebuild
the kernel image.  Compare this to changing the kernel command line from
"root=/dev/hda1" to "root=/dev/nfs ip=dhcp" in the boot loader by hitting
a few keys on the keyboard before the kernel loads, and I think you'll
start to get my point here.

-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html
