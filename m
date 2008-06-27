From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: How come realtek drivers are combined
Date: Fri, 27 Jun 2008 21:18:35 +0200
Message-ID: <20080627191835.GA5064@electric-eye.fr.zoreil.com>
References: <4864235A.40807@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, edward_hsu@realtek.com.tw
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60120 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757327AbYF0TSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 15:18:49 -0400
Content-Disposition: inline
In-Reply-To: <4864235A.40807@dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mario Limonciello <mario_limonciello@dell.com> :
[...]
> Realtek provides several (separated) drivers for their different
> chipsets, r8169, r8168, r8101, etc. I see that they are regularly all
> merged into the r8169 driver in the kernel. How come it works this
> way ?

I made it this way.

> Is it just because no one ever bothered to do it differently ? 

It was suggested before but it was not strongly argumented and I have
a strong bias against it as long as it is not clearly needed.

> Obviously, they all share a very similar code base so its somewhat
> sensible to try to produce a single driver. 

It was.

I'll probably end splitting things between the old pci-only 8169 and
the newest pci-e though.

> I would think it would work a lot better for everyone if Realtek and
> the kernel maintainers that work on the Realtek driver were directly
> in sync rather than having to play tag pulling patches from each other's
> drivers.

Given that the choice of operating systems for laptops on Dell's online
shop does not include my favorite OS, "everyone" seems a bit of an
overstatement to me (sorry, could not resist :o) ).

Compare two versions of the same driver from Realtek and you should
realize that you are addressing a false problem.

-- 
Ueimor
