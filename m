From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] sa1100ir - fix for 2.6
Date: Fri, 5 Dec 2003 16:30:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031206003018.GA2941@bougret.hpl.hp.com>
References: <20031205150601.68c52de3.shemminger@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <rmk@arm.linux.org.uk>, Jeff Garzik <jgarzik@pobox.com>,
        Alexander Viro <aviro@redhat.com>, netdev@oss.sgi.com,
        irda-users@sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031205150601.68c52de3.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Dec 05, 2003 at 03:06:01PM -0800, Stephen Hemminger wrote:
> Update the ARM SA1100 irda driver to current 2.6 network device model
>   * allocate network device with alloc_irdadev - get rid of dev_alloc
>   * change to current system device class model - looks like it was using early
>     old version of interface from 2.5
>   * better error unwind
> 
> This has been cross compiled successfully against net-drivers-2.5-exp

	I don't have the hardware, so I can't test that (and I'm not
familiar with sysfs). If you want, I can add that as part of my next
IrDA update (probably 2.6.1).
	Russel, if you do testing you may want to grab the "F-timer
fix" from my web page.
	Regards,

	Jean
