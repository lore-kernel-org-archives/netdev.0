From: David McCullough <davidm@snapgear.com>
Subject: Re: pm_register should die
Date: Tue, 13 Sep 2005 10:03:35 +1000
Message-ID: <20050913000335.GA10418@beast>
References: <20050912093456.GA29205@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel list <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@zip.com.au>,
	Linus Torvalds <torvalds@osdl.org>, vojtech@suse.cz,
	dwmw2@infradead.org, netdev@vger.kernel.org,
	benjamin_kong@ali.com.tw, dagb@cs.uit.no, jgarzik@pobox.com,
	twoller@crystal.cirrus.com, alan@redhat.com, mm@caldera.de,
	scott@spiteful.org, jsimmons@transvirtual.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932380AbVIMAEF@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Content-Disposition: inline
In-Reply-To: <20050912093456.GA29205@elf.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jivin Pavel Machek lays it down ...
> Hi!
> 
> pm_register has been obsoleted by driver model, and it was deprecated
> quite long time ago. There are only 13 users left.
> 
> Attached is a patch that makes pm_register config-option, so that we
> don't get the warnings on sane systems. Pretty please, remove usage of
> pm_register from your subsystem.
> 
> IRDA has no usefull MAINTAINER entry; it would be nice if that could
> be fixed. Alan is best contact I could find for ad1848... does someone
> care about that driver, anyway? nm256_audio is written by
> anonymous. Wonderfull...
> 
> Okay, it seems to me only users that matter are mtdcore, 3c509 and
> maybe h3600_ts_input. After those are fixed, it should be okay to just
> config it out/remove pm_register completely.

Feel free to clean out pm_register usage in:

	drivers/serial/68328serial.c

there's not much in there that cannot be added later if actually required,

Cheers,
Davidm

-- 
David McCullough, davidm@cyberguard.com.au, Custom Embedded Solutions + Security
Ph:+61 734352815 Fx:+61 738913630 http://www.uCdot.org http://www.cyberguard.com
