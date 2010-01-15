From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Regression: Wake on LAN doesn't work in sky2 with
 2.6.33-rc4-git2
Date: Fri, 15 Jan 2010 10:50:59 -0800
Message-ID: <20100115105059.251a3717@nehalam>
References: <20100115091053.GA5477@mac.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tino Keitel <tino.keitel@tikei.de>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55821 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423Ab0AOSv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2010 13:51:26 -0500
In-Reply-To: <20100115091053.GA5477@mac.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Jan 2010 10:10:53 +0100
Tino Keitel <tino.keitel@tikei.de> wrote:

> Hi,
> 
> wake on LAN doesn't work with 2.6.33-rc4-git2 on the following
> hardware:
> 
> 01:00.0 Ethernet controller [0200]: Marvell Technology Group Ltd.
> 88E8053 PCI-E Gigabit Ethernet Controller [11ab:4362] (rev 22)
> 
> It worked with 2.6.32. In my suspend script, I enable WoL using
> ethtool:
> 
> ethtool -s eth0 wol g
> 
> in dmesg, I get these messages at suspend:
> 
> sky2 eth0: disabling interface
> sky2 0000:01:00.0: PME# enabled
> sky2 0000:01:00.0: wake-up capability enabled by ACPI
> 
> and at resume:
> 
> sky2 0000:01:00.0: wake-up capability disabled by ACPI
> sky2 0000:01:00.0: PME# disabled
> 
> Regards,
> Tino

This has already been reported.

Rafael has been doing the generic PM stuff.
Look for thread,
 [Bug 14730] sky2 won't work after suspend/resume cycle
