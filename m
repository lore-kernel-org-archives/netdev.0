From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [PATCH] sa1100ir - fix for 2.6
Date: Sat, 6 Dec 2003 08:38:11 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031206083811.A9622@flint.arm.linux.org.uk>
References: <20031205150601.68c52de3.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        Alexander Viro <aviro@redhat.com>, netdev@oss.sgi.com,
        irda-users@sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031205150601.68c52de3.shemminger@osdl.org>; from shemminger@osdl.org on Fri, Dec 05, 2003 at 03:06:01PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Dec 05, 2003 at 03:06:01PM -0800, Stephen Hemminger wrote:
> Update the ARM SA1100 irda driver to current 2.6 network device model
>   * allocate network device with alloc_irdadev - get rid of dev_alloc
>   * change to current system device class model - looks like it was using early
>     old version of interface from 2.5
>   * better error unwind

It isn't a system device though.  Please revery the sysdev changes.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
