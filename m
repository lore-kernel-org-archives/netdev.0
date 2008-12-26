From: Pavel Machek <pavel@suse.cz>
Subject: Re: [1/9] pohmelfs: documentation.
Date: Fri, 26 Dec 2008 20:22:20 +0100
Message-ID: <20081226192219.GB1761@ucw.cz>
References: <1230301130-1325-1-git-send-email-zbe@ioremap.net> <1230301130-1325-2-git-send-email-zbe@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, pohmelfs@ioremap.net,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Eveniy Polyakov <zbr@ioremap.net>
To: Evgeniy Polyakov <zbe@ioremap.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1230301130-1325-2-git-send-email-zbe@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> +Homepage: http://www.ioremap.net/projects/pohmelfs
> +
> +POHMELFS first began as a network filesystem with coherent local data and
> +metadata caches but is now evolving into a parallel distributed filesystem.
> +
> +Main features of this FS include:
> + * Locally coherent cache for data and metadata with (potentially) byte-range locks.
> +	Since all Linux filesystems lock the whole inode during writing, algorithm
> +	is very simple and does not use byte-ranges, although they are sent in
> +	locking messages.
> + * Completely async processing of all events except creation of hard and symbolic
> +	links, and rename events.
> +	Object creation and data reading and writing are processed asynchronously.
> + * Flexible object architecture optimized for network processing.
> +	Ability to create long paths to objects and remove arbitrarily huge
> +	directories with a single network command.
> +	(like removing the whole kernel tree via a single network
> command).

Hmm, so we'll need new unlink_recursively() syscall?

> + * Very high performance.

Do you have some nfs comparison?
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
