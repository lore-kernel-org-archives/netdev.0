From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: Upcoming cross-tree build breakage on merge window
Date: Tue, 19 Feb 2013 20:44:07 +0100
Message-ID: <CACna6rwYZWsGhb8ksko+XGvod=hVyVHu2QrCfEisTG=YAEfBRQ@mail.gmail.com>
References: <CACna6ryD3SjLN-oauvVuRa+q7an8DaULj+Uj4bwFSzQf2WCvMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-mips@linux-mips.org,
	Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: john@phrozen.org, ralf@linux-mips.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:53010 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933048Ab3BSToH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 14:44:07 -0500
Received: by mail-ob0-f171.google.com with SMTP id x4so6966684obh.2
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 11:44:07 -0800 (PST)
In-Reply-To: <CACna6ryD3SjLN-oauvVuRa+q7an8DaULj+Uj4bwFSzQf2WCvMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/23 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
> I've noticed possible build breakage when two trees get merged:
> net-next and linux-john (MIPS).
>
> This is about two following commits:
> http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next.git;a=3Dco=
mmit;h=3Ddd4544f05469aaaeee891d7dc54d66430344321e
> http://git.linux-mips.org/?p=3Djohn/linux-john.git;a=3Dcommit;h=3Da00=
8ca117bc85a9d66c47cd5ab18a6c332411919
>
> The first one adds "bgmac" driver which uses asm/mach-bcm47xx/nvram.h
> and nvram_getenv. The second one renames them.
>
> Can you handle this in some clever way during merge window, please?
>
> The fix is trivial:
> 1) Use <bcm47xx_nvram.h>
> 2) Use bcm47xx_nvram_getenv

Just a reminder.

--=20
Rafa=C5=82
