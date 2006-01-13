From: Jens Axboe <axboe@suse.de>
Subject: Re: [git patches] 2.6.x net driver updates
Date: Fri, 13 Jan 2006 20:23:16 +0100
Message-ID: <20060113192316.GX3945@suse.de>
References: <20060112221322.GA25470@havoc.gtf.org> <Pine.LNX.4.64.0601121423120.3535@g5.osdl.org> <20060112143938.5cf7d6a5.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Roman Zippel <zippel@linux-m68k.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422846AbWAMTVk@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060112143938.5cf7d6a5.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 12 2006, Andrew Morton wrote:
> Linus Torvalds <torvalds@osdl.org> wrote:
> >
> > On Thu, 12 Jan 2006, Jeff Garzik wrote:
> >  > 
> >  > dann frazier:
> >  >       CONFIG_AIRO needs CONFIG_CRYPTO
> > 
> >  I think this is done wrong.
> > 
> >  It should "select CRYPTO" rather than "depends on CRYPTO".
> > 
> >  Otherwise people won't see it just because they don't have crypto enabled, 
> >  which is not very user-friendly.
> > 
> 
> Yes, I think that's much more Aunt-Nellie-friendly, but Roman considers it
> abuse of the Kconfig system in ways which I never completely understood?

'select' is really cool as a concept, but when you can't figure out why
you cannot disable CONFIG_FOO because CONFIG_BAR selects it it's really
annoying. Would be nice to actually be able to see if another option has
selected this option.

-- 
Jens Axboe
