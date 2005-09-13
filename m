From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: pm_register should die
Date: Tue, 13 Sep 2005 02:32:01 +0100
Message-ID: <1126575121.31228.11.camel@localhost.localdomain>
References: <20050912093456.GA29205@elf.ucw.cz>
	 <20050913000335.GA10418@beast>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@zip.com.au>,
	Linus Torvalds <torvalds@osdl.org>, vojtech@suse.cz,
	dwmw2@infradead.org, netdev@vger.kernel.org,
	benjamin_kong@ali.com.tw, dagb@cs.uit.no, jgarzik@pobox.com,
	twoller@crystal.cirrus.com, alan@redhat.com, mm@caldera.de,
	scott@spiteful.org, jsimmons@transvirtual.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932391AbVIMBKW@vger.kernel.org>
To: David McCullough <davidm@snapgear.com>
In-Reply-To: <20050913000335.GA10418@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > be fixed. Alan is best contact I could find for ad1848... does someone
> > care about that driver, anyway? nm256_audio is written by
> > anonymous. Wonderfull...

AD1848 docs are public, NM256 was reverse engineered so no docs. Most
users are now using the ALSA layer. It might be simplest to kill
pm_register after OSS goes, which is now scheduled anyway.
