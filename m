From: Daniel Drake <dsd@gentoo.org>
Subject: Re: Problems with sky2 driver.
Date: Mon, 24 Jul 2006 18:57:24 +0100
Message-ID: <44C50A04.5020002@gentoo.org>
References: <20060724133829.49bf7979@akemi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:17216 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932238AbWGXRtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 13:49:52 -0400
To: Todd Showalter <tshowalter@silverbirchstudios.com>
In-Reply-To: <20060724133829.49bf7979@akemi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Todd Showalter wrote:
>     I've been having trouble with the sky2 driver.  It appears to work
> most of the time, but it will quite often wedge during transfers.  The
> 2.6.17.* kernels actually seem worse than 2.6.16.19, but none of them
> work perfectly.
> 
>     What typically happens is that after working perfectly for a while,
> existing net connections hang, and subsequent net connections don't
> seem to start at all.  firefox gets stuck with a bunch of half-loaded
> pages, for instance, and I've watched an scp of a large file to a
> colleague's machine stall and remain stalled.

Please test with the very latest git snapshot. A critical fix was 
applied after 2.6.18-rc2 was released.

>     Once the machine is behaving this way, a reboot is the only way I
> have found of recovering it.
> 
>     We have two identical machines here that are both behaving this
> way, so I'm assuming it's not a hardware problem per se.  The machines
> are Intel Pentium D 940 (3GHz) processors.  They have ASUS P5LD2
> motherboards, with builtin Marvell PCIe 88E8053 gigabit ethernet
> controllers.
> 
>     I'm not running any binary modules; it's an untainted kernel.  I'm
> running a Gentoo system, but I'm using the vanilla-sources kernel (ie:
> a pure kernel.org release, not the Gentoo-specific patched version).
> 
>     What can I do to help solve this?

