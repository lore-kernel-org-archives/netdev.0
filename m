From: Christian Kujau <christian@g-house.de>
Subject: Re: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Tue, 3 Apr 2007 06:46:40 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0704030634470.3963@sheep.housecafe.de>
References: <Pine.LNX.4.64.0704022012300.3963@sheep.housecafe.de>
 <200704030120.29619.lenb@kernel.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	malte@g-house.de
To: Len Brown <lenb@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.g-housing.de ([81.169.133.75]:35605 "EHLO mail.g-house.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753077AbXDCFqq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 01:46:46 -0400
In-Reply-To: <200704030120.29619.lenb@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Apr 2007, Len Brown wrote:
> Which increased stability, disabling ACPI, or disabling the IOAPIC?

To be honest, we're not sure. See below.

> Your box has MPS, so you should be able to use the IOAPIC in either mode.

MPS - Multiprocessor Specification? SMP? Yes, it'd be good to use the 
IOAPIC again.

> Note that you can do these both independently at boot-time with "acpi=off"
> and "noapic", respectively.
> eg. 4 combos
> 1. <default - no boot params>
> 2. noapic
> 3. acpi=off
> 4. acpi=off noapic
> you started with #1, and are running hard-coded #4 now, but skipped #2 
> and #3

Indeed, we skipped quite a few options. As mentioned before, the boxes 
are in production already so we don't have much time to play around and
we were just happy when they survived a few hours :(

But yes, we'll try booting with "acpi=off" and enabled IOAPIC again.

@Malte: when will we be able to do so?

Len et al., do you even suggest to use ACPI on a server system at all? I 
myself always thought of ACPI being evil and to avoid when possible 
(thus switching it off completely on a serversystem).

Since these NETDEV WATCHDOG issues seems to be a "known issue" (kinda, 
since the many postings on the lists in the past), is there something 
else we should look into? Would more debug .config options help to find 
out why they lock up?

Thanks for your comments,
Christian.
-- 
BOFH excuse #340:

Well fix that in the next (upgrade, update, patch release, service pack).
