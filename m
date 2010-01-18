From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: linux-next build failure (was: Re: [PATCH/REPOST] pci: push
	deprecated pci_find_device() function to last user)
Date: Mon, 18 Jan 2010 15:44:27 +0100
Message-ID: <10f740e81001180644yd44121cv6dd963349563a290@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tilman Schmidt <tilman@imap.cc>,
	David Miller <davem@davemloft.net>, Greg KH <gregkh@suse.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:25666 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884Ab0AROo3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 09:44:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2010 at 19:08, Jesse Barnes <jbarnes@virtuousgeek.org> =
wrote:
> On Thu, 14 Jan 2010 23:18:41 +0100 (CET)
> Tilman Schmidt <tilman@imap.cc> wrote:
>
>> Am 14.01.2010 17:28 schrieb Jesse Barnes:
>> > I can take it, but I lost the original patch. =C2=A0Tilman, can yo=
u
>> > resend?
>>
>> Sure, here you are:
>>
>> Subject: [PATCH] pci: push deprecated pci_find_device() function to
>> last user
>>
>> The ISDN4Linux HiSax driver family contains the last remaining users
>> of the deprecated pci_find_device() function. This patch creates a
>> private copy of that function in HiSax, and removes the now unused
>> global function together with its controlling configuration option,
>> CONFIG_PCI_LEGACY.
>>
>> Impact: code reorganization, no functional change
>> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
>> ---
>> Note: This patch is not, nor does it intend to be, checkpatch.pl
>> clean. The issues checkpatch.pl reports on it were already present
>> before, and are unrelated to the topic of this patch.
>
> Applied to my linux-next branch, thanks Tilman.

Just guessing: something's wrong if CONFIG_PCI is not set?

http://kisskb.ellerman.id.au/kisskb/buildresult/2042085/

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
							    -- Linus Torvalds
