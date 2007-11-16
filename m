From: Martin Michlmayr <tbm@cyrius.com>
Subject: Netconsole and logging everything from /dev/console
Date: Fri, 16 Nov 2007 18:43:15 +0100
Message-ID: <20071116174315.GA20401@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hpa@zytor.com
To: Matt Mackall <mpm@selenic.com>,
	Satyam Sharma <satyam.sharma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:2978 "EHLO sorrow.cyrius.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751631AbXKPSGj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 13:06:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm supporting a number of consumer devices (e.g. small NAS devices)
in Debian.  They typically don't export the serial console and don't
have any other output devices.  We perform the installation via SSH
on such devices and start SSH automatically when the system boots so
people can login.  This works pretty well but sometimes a device stops
to boot for no good reason.  This is usually really hard to debug
since we don't have any logs at all.

I could activate netconsole in order to see kernel messages but then I
still wouldn't see anything that's printed by the ramdisk and later
when services are started.  Ideally, I'd like to have an option for
netconsole to show every message that is also shown on the console.

Do you think that would be possible?
-- 
Martin Michlmayr
http://www.cyrius.com/
