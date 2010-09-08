From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: NFS writes broken in net-next-2.6
Date: Wed, 08 Sep 2010 21:14:10 +0100
Message-ID: <1283976850.2237.9.camel@achroite.uk.solarflarecom.com>
References: <1283976068.2237.8.camel@achroite.uk.solarflarecom.com>
	 <20100908.130550.115952209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100908.130550.115952209.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-08 at 13:05 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
> Date: Wed, 08 Sep 2010 21:01:08 +0100
> 
> > In net-next-2.6, close() of a file after writing tends to return 1.
> > This causes e.g. gcc to abort.
> > 
> > This appears to have been fixed in 2.6.36-rc2:
> > 
> > commit 0702099bd86c33c2dcdbd3963433a61f3f503901
> > Author: J. R. Okajima <hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org>
> > Date:   Wed Aug 11 13:10:16 2010 -0400
> > 
> >     NFS: fix the return value of nfs_file_fsync()
> > 
> > Please consider merging this fix in some way.
> 
> Ben, and please I've told you this before,

I don't think so.

> if you need a specific
> upstream fix do your testing on a branch that pulls in Linus's tree
> or, alternatively, apply the fix you need by hand using "git stash" or
> similar.
[...]

Sure, that's what I'm doing.  But this is likely to hit more developers
than just me.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
