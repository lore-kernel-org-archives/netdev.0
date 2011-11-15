From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH] r8169: add module param for control of ASPM disable
Date: Tue, 15 Nov 2011 16:32:40 +0000
Message-ID: <20111115163240.GA5549@srcf.ucam.org>
References: <1321052755-15368-1-git-send-email-tbroch@chromium.org>
 <20111112045935.GA24292@srcf.ucam.org>
 <20111112104624.GA24870@electric-eye.fr.zoreil.com>
 <CA+iF6Rog3ptpmQZzhcRODmZUKN18_uw5t9xfpQjbJ86qKUA0eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Todd Broch <tbroch@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:59137 "EHLO
	cavan.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756540Ab1KOQcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 11:32:46 -0500
Content-Disposition: inline
In-Reply-To: <CA+iF6Rog3ptpmQZzhcRODmZUKN18_uw5t9xfpQjbJ86qKUA0eQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2011 at 08:27:41AM -0800, Todd Broch wrote:
> On Sat, Nov 12, 2011 at 2:46 AM, Francois Romieu <romieu@fr.zoreil.com>wrote:
> >
> > Re-visiting the original change that disabled ASPM,
> 
> http://www.google.com/url?q=http%3A//git.kernel.org/%3Fp%3Dlinux/kernel/git/torvalds/linux-2.6.git%3Ba%3Dcommit%3Bh%3Dba04c7c93bbcb48ce880cf75b6e9dffcd79d4c7b&usg=AFQjCNFfPARrhwg-nBtW09W_n4qr1hgvdA
> 
> Led me to,
>   https://bugzilla.redhat.com/show_bug.cgi?id=642861#c4
> 
> This comment by tomi.leppikangas@, is later re-canted as a h/w issue in,
>  https://bugzilla.redhat.com/show_bug.cgi?id=642861#c9
>    'I am now pretty sure that my problems were caused by faulty hardware.
> Cpu or
>     motherboard seems to be broken, so pcie_aspm=off  didnt help for me.
> Sorry
>     about misleading info.'

Mike Khusid's issue was fixed by disabling ASPM.

> My assement from above is that ASPM was disabled prematurely and given the
> power
> savings should be re-enabled.

Power savings are great. I'm all in favour of power savings. But not 
when they break otherwise working setups.

> I'd certainly be agreeable to switching the assertion of patch to default
> being disabled.
> Unfortunately I fear that means most will never benefit from the power
> savings.

I'd recommend working with your hardware partners to figure out which 
parts are expected to work and which aren't. There's no problem with 
making this code conditional on product ID or version.

-- 
Matthew Garrett | mjg59@srcf.ucam.org
