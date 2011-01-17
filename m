From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: Merging SSB and HND/AI support
Date: Mon, 17 Jan 2011 11:46:25 +0100
Message-ID: <AANLkTi=GDcy50zsC6=Dgv1-Ty3cYK2qpx9o=q3JdXuCh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Michael Buesch <mb@bu3sch.de>, linux-mips@linux-mips.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:44540 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497Ab1AQKqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 05:46:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am currently looking into adding support for the newer Broadcom
BCM47xx/53xx SoCs. They require having HND/AI support, which probably
means merging the current SSB code and the HND/AI code from the
brcm80211 driver. Is anyone already working on this?

As far as I can see, there are two possibilities:

a) Merge the HND/AI code into the current SSB code, or

b) add the missing code for SoCs to brcm80211 and replace the SSB code with it.

The former is probably the less intrusive one, but requires a bit of
ssb-named-but-actually-not-ssb code unless one renames several
functions and structs.

The latter has the advantage of having a certain bus abstraction
already built-in, but would require adapting the b43 code to it. It
also looks like it doesn't support (very) old SoCs.

Regards,
Jonas

P.S: The Maintainers file says SSB's list is netdev, but I would have
expected it to be linux-wireless. Is this still correct?
