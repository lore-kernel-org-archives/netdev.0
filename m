From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Date: Wed, 2 Jan 2013 20:47:12 +0000
Message-ID: <20130102204712.GA17806@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20130102200848.GA4500@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Eric Wong <normalperson@yhbt.net> wrote:
> [1] my full setup is very strange.
> 
>     Other than the FUSE component I forgot to mention, little depends on
>     the kernel.  With all this, the standalone toosleepy can get stuck.
>     I'll try to reproduce it with less...

I just confirmed my toosleepy processes will get stuck while just
doing "rsync -a" between local disks.  So this does not depend on
sendfile or FUSE to reproduce.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
