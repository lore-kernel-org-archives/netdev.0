From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Wed, 19 Nov 2014 16:53:40 -0500 (EST)
Message-ID: <20141119.165340.2162829993279387495.davem@davemloft.net>
References: <CA+55aFyQR2gOzEDROcWFcQzLvTjOxyJRjFJXJ03JB5knd-Gsgg@mail.gmail.com>
	<20141119.161744.1661940121298888832.davem@davemloft.net>
	<20141119213006.GE7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141119213006.GE7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Wed, 19 Nov 2014 21:30:07 +0000

> On Wed, Nov 19, 2014 at 04:17:44PM -0500, David Miller wrote:
>> > Seeing a "__get_user()" and just being able to glance up in the same
>> > function and seeing the "access_ok()" is just a good safety net. And
>> > means that people don't have to waste time thinking about or looking
>> > for where the hell the security net really is.
>> 
>> Fair enough.
> 
> OK, with 3/5 dropped 4/5 get a trivial conflict (removal of function in 4/5
> vs. change in it in 3/5).  With that dealt with, the sucker is in
> git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git for-davem
> 
> Shortlog:
> Al Viro (4):
>       separate kernel- and userland-side msghdr
>       {compat_,}verify_iovec(): switch to generic copying of iovecs
>       fold verify_iovec() into copy_msghdr_from_user()
>       bury skb_copy_to_page()

Pulled, thanks Al.
