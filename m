From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] natsemi update 1/4 Use assigned MAC address
Date: Mon, 7 Jun 2004 11:16:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607111638.663de0a6@dell_ss3.pdx.osdl.net>
References: <200406041451590078.0BC23855@136.179.85.112>
	<40C31C71.6000101@colorfullife.com>
	<200406071258550931.1ACDCC8B@136.179.85.112>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Gary N Spiess" <Gary.Spiess@Intermec.com>
In-Reply-To: <200406071258550931.1ACDCC8B@136.179.85.112>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 07 Jun 2004 12:58:55 -0500
"Gary N Spiess" <Gary.Spiess@Intermec.com> wrote:

> Jeff,
> 
> I agree with all comments.  Regarding the total elimination of this patch ...
> 
> Only our bootrom knows the MAC address that should be used, and it appends it to the bootargs.  If there is a way for the userspace to take a peek at the bootargs (or a similar mechanism), we can use the ifconfig method to assign the MAC address instead of changing the driver.  I'd prefer it.

/proc/cmdline??
