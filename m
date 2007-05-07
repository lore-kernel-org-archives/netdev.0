From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [-mm patch] fix fs/nfs/nfsroot.c compile error
Date: Mon, 7 May 2007 12:56:07 +0200
Message-ID: <20070507105607.GB4226@stusta.de>
References: <20070505164422.GD8975@stusta.de> <20070505014955.8f3990b5.akpm@linux-foundation.org> <15958.1178534871@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	trond.myklebust@fys.uio.no, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:40445 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932659AbXEGK4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 06:56:07 -0400
Content-Disposition: inline
In-Reply-To: <15958.1178534871@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 07, 2007 at 11:47:51AM +0100, David Howells wrote:
> Adrian Bunk <bunk@stusta.de> wrote:
> 
> > match_table_t was made "const" and gcc doesn't like "const __initdata":
> 
> Hmmm...  My gcc seems quite happy with it.  What gcc are you using?

4.1

> Shouldn't __initdata override const?
> 
> > BTW: Why is this change to include/linux/parser.h in the net tree?
> 
> Because DaveM picked it up as part of my AFS patches, I guess.

It might make sense, but it doesn't seem to be in any way AFS specific.

> David

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

