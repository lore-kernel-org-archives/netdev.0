From: Matt Mackall <mpm@selenic.com>
Subject: Re: Netconsole and logging everything from /dev/console
Date: Fri, 16 Nov 2007 12:50:36 -0600
Message-ID: <20071116185036.GH19691@waste.org>
References: <20071116174315.GA20401@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Satyam Sharma <satyam.sharma@gmail.com>, netdev@vger.kernel.org,
	hpa@zytor.com
To: Martin Michlmayr <tbm@cyrius.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:36836 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751164AbXKPSvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 13:51:22 -0500
Content-Disposition: inline
In-Reply-To: <20071116174315.GA20401@deprecation.cyrius.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 16, 2007 at 06:43:15PM +0100, Martin Michlmayr wrote:
> I'm supporting a number of consumer devices (e.g. small NAS devices)
> in Debian.  They typically don't export the serial console and don't
> have any other output devices.  We perform the installation via SSH
> on such devices and start SSH automatically when the system boots so
> people can login.  This works pretty well but sometimes a device stops
> to boot for no good reason.  This is usually really hard to debug
> since we don't have any logs at all.
> 
> I could activate netconsole in order to see kernel messages but then I
> still wouldn't see anything that's printed by the ramdisk and later
> when services are started.  Ideally, I'd like to have an option for
> netconsole to show every message that is also shown on the console.
> 
> Do you think that would be possible?

It is, definitely, you just need to wire up a tty struct's write
method to netconsole's and add it to the console registration. But I
haven't had any time to work on this in a while.

-- 
Mathematics is the supreme nostalgia of our time.
