From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: sky2 patch in 2.6.24-rc7-git6 breaks POST - commit
 84cd2dfb04d23a961c5f537baa243fa54d0987ac
Date: Tue, 15 Jan 2008 10:09:47 -0800
Message-ID: <20080115100947.4ec6cda0@deepthought>
References: <df47b87a0801150301w6b970decwdd4bd256aa2ca9ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
To: "Ioan Ionita" <opslynx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:56809 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259AbYAOSMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 13:12:30 -0500
In-Reply-To: <df47b87a0801150301w6b970decwdd4bd256aa2ca9ac@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Jan 2008 13:01:47 +0200
"Ioan Ionita" <opslynx@gmail.com> wrote:

> Hi,
> 
> I have an Asus Commando motherboard, p965 chipset with Marvell
> 88E8056 and 88E8001 gigabit lan onboard. skge and sky2 are compiled
> in.
> When booting linux-2.6.24-rc7-git6, everything seemed fine, but when
> attempting to reboot, the machine would freeze on POST, right before
> detecting AHCI drives.
> In order to get it to POST, a reset or shutdown from the power button
> is not enough, I actually have to cut power to the motherboard using
> the PSU's power switch!
> 
> I first thought that the BIOS or CMOS may have gotten corrupted, but
> eventually I fund that linux was the culprit. After a git bisect, I
> found the bad commit below
> 

Is Wake On Lan enabled in the BIOS?

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
