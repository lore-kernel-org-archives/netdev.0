From: Jens Axboe <axboe@suse.de>
Subject: Re: kernel BUG at net/core/skbuff.c:1028!
Date: Wed, 7 May 2003 14:50:27 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030507125027.GK823@suse.de>
References: <20030507121412.GI823@suse.de> <20030507.042035.13750321.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030507.042035.13750321.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Wed, May 07 2003, David S. Miller wrote:
>    From: Jens Axboe <axboe@suse.de>
>    Date: Wed, 7 May 2003 14:14:12 +0200
> 
>    Booting 2.5-BK on my little router BUG's out before the login is
>    reached. 100% reproduceable. Let me know if you want more detail.
> 
> I forwarded this to Rusty, I think netfilter changes he made
> recently have caused this.

Backing out this puppy:

http://www.kernel.org/pub/linux/kernel/v2.5/testing/cset/cset-rusty@rustcorp.com.au|ChangeSet|20030506080426|32903.txt

makes it work. Ruuuuusty?

-- 
Jens Axboe
