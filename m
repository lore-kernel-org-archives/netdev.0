From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: sky2 patch in 2.6.24-rc7-git6 breaks POST - commit
 84cd2dfb04d23a961c5f537baa243fa54d0987ac
Date: Tue, 15 Jan 2008 11:16:04 -0800
Message-ID: <20080115111604.189727f5@deepthought>
References: <df47b87a0801150301w6b970decwdd4bd256aa2ca9ac@mail.gmail.com>
	<20080115100947.4ec6cda0@deepthought>
	<df47b87a0801151100qe7c39f1y3296176f343667eb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
To: "Ioan Ionita" <opslynx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:58165 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751139AbYAOTSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 14:18:49 -0500
In-Reply-To: <df47b87a0801151100qe7c39f1y3296176f343667eb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Jan 2008 21:00:13 +0200
"Ioan Ionita" <opslynx@gmail.com> wrote:

> On Jan 15, 2008 8:09 PM, Stephen Hemminger <stephen.hemminger@vyatta.com> wrote:
> > On Tue, 15 Jan 2008 13:01:47 +0200
> > "Ioan Ionita" <opslynx@gmail.com> wrote:
> >
> 
> >
> > Is Wake On Lan enabled in the BIOS?
> 
> I don't have a Wake on Lan option in BIOS, only wake on pci, i assume
> it's the same.  It was disabled. I enabled it and the regression
> behaved the same way.  Wouldn't POST after shutdown or soft reset.
> 

I assume if you do:
	ethtool -s eth0 wol d

it will POST okay.  Okay, for now I'll have Jeff revert the patch.
Looks like the BIOS in your system is broken for WOL.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
