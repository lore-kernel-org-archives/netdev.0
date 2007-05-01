From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 2/2] AFS/AF_RXRPC: Miscellaneous fixes
Date: Tue, 1 May 2007 20:08:10 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0705012006050.27246@anakin>
References: <20070501174747.19112.1985.stgit@warthog.cambridge.redhat.com>
 <20070501174752.19112.82814.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	Linux Kernel Development <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755252AbXEASIN@vger.kernel.org>
In-Reply-To: <20070501174752.19112.82814.stgit@warthog.cambridge.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi David,

I've just noticed another issue: if CONFIG_AFS_FS=y, the kernel build fails
with

| `afs_callback_update_kill' referenced in section `.init.text' of fs/built-in.o: defined in discarded section `.exit.text' of fs/built-in.o
| `afs_vlocation_purge' referenced in section `.init.text' of fs/built-in.o: defined in discarded section `.exit.text' of fs/built-in.o

and indeed, afs_init() calls both afs_callback_update_kill() and
afs_vlocation_purge() in the failure path.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
