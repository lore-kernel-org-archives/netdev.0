From: Andrew Morton <akpm@osdl.org>
Subject: Re: [git patches] 2.6.x net driver updates
Date: Thu, 12 Jan 2006 14:39:38 -0800
Message-ID: <20060112143938.5cf7d6a5.akpm@osdl.org>
References: <20060112221322.GA25470@havoc.gtf.org>
	<Pine.LNX.4.64.0601121423120.3535@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Roman Zippel <zippel@linux-m68k.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161377AbWALWmS@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0601121423120.3535@g5.osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@osdl.org> wrote:
>
> On Thu, 12 Jan 2006, Jeff Garzik wrote:
>  > 
>  > dann frazier:
>  >       CONFIG_AIRO needs CONFIG_CRYPTO
> 
>  I think this is done wrong.
> 
>  It should "select CRYPTO" rather than "depends on CRYPTO".
> 
>  Otherwise people won't see it just because they don't have crypto enabled, 
>  which is not very user-friendly.
> 

Yes, I think that's much more Aunt-Nellie-friendly, but Roman considers it
abuse of the Kconfig system in ways which I never completely understood?
