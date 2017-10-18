From: Adam Borowski <kilobyte@angband.pl>
Subject: Re: [PATCH] wanxl: use m68k-linux-gnu-as if available
Date: Wed, 18 Oct 2017 13:33:26 +0200
Message-ID: <20171018113326.2rkpe7wrlzihwdyb@angband.pl>
References: <20171012232434.15890-1-kilobyte@angband.pl>
 <20171018.120812.879877583327430024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tartarus.angband.pl ([89.206.35.136]:35348 "EHLO
        tartarus.angband.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753562AbdJRLd3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 07:33:29 -0400
Content-Disposition: inline
In-Reply-To: <20171018.120812.879877583327430024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 12:08:12PM +0100, David Miller wrote:
> From: Adam Borowski <kilobyte@angband.pl>
> Date: Fri, 13 Oct 2017 01:24:34 +0200
> 
> > This fixes build failure on Debian based systems: GNU as is the only m68k
> > assembler available in the archive (package binutils-m68k-linux-gnu).
> > 
> > Signed-off-by: Adam Borowski <kilobyte@angband.pl>
> 
> The Kconfig help text for the config option controlling the build
> firmware is extremely clear what the requirements are for enabling
> that option.
> 
> And that is: "It requires as68k, ld68k and hexdump programs."

Yeah, but as far as I know, as68k is a name of "GNU as"; Debian calls the
same m68k-linux-gnu-as (and in general, $(GNU_TRIPLET)-as for all usual
cross toolchains shipped).  And as Debian derivatives make the majority of
distro installs these days, supporting its naming scheme would be
convenient.

Or, if you believe no one should try to build this firmware from source,
it might be better to annotate it to be excluded from randconfig builds.


Meow!
-- 
⢀⣴⠾⠻⢶⣦⠀ 
⣾⠁⢰⠒⠀⣿⡁ Imagine there are bandits in your house, your kid is bleeding out,
⢿⡄⠘⠷⠚⠋⠀ the house is on fire, and seven big-ass trumpets are playing in the
⠈⠳⣄⠀⠀⠀⠀ sky.  Your cat demands food.  The priority should be obvious...
