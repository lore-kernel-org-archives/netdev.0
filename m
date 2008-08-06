From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: Realtek 8111C transmit timed out
Date: Wed, 6 Aug 2008 21:37:45 +0200 (CEST)
Message-ID: <25625.84.245.32.19.1218051465.squirrel@secure.greenhost.nl>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com>
    <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com>
    <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com>
    <20080805214250.GA23226@electric-eye.fr.zoreil.com>
    <loom.20080806T144054-201@post.gmane.org>
    <20080806181235.GA17174@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost1.greenhost.nl ([85.17.153.87]:34787 "EHLO
	smarthost1.samage.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbYHFT77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 15:59:59 -0400
In-Reply-To: <20080806181235.GA17174@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, August 6, 2008 20:12, Francois Romieu wrote:
> Indan Zupancic <indan@nul.nu> :
> [...]
>> I'm running a git version just before 2.6.27-rc2 and while the card
>> worked fine in 2.6.26, after a resume from suspend to ram I now get:
>
> You cab try to revert the four (4) r8169.c related patches that went
> in between 2.6.26 and 2.6.27-rc1. I doubt it will make a difference
> though.

"git log drivers/net/r8169.c" shows only two commits since May 11:

r8169: avoid thrashing PCI conf space above RTL_GIGA_MAC_VER_06

r8169: multicast register update

Then at May 11 comes:

r8169: remove non-napi code

But I think that was in 2.6.26 already.

Reverting the first two didn't help, so I guess it's messed up
somewhere else.

Are two patches missing or didn't they touch r8169.c?

I tried manually reverting patch

0004-r8169-new-phy-init-parameters-for-the-8168b.patch

(misread your mail), and it didn't seem applied yet.

> Is a git bisect an option ?

Yes, but it takes quite a lot of time and I'm busy at the moment,
so I'll wait till rc2 to see if it's fixed then. If it isn't I'll
start digging.

Greetings,

Indan


