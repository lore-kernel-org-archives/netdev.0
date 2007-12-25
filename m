From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [WEXT 3/12]: Extract standard call iw_point handling into
 seperate function.
Date: Mon, 24 Dec 2007 21:18:45 -0800 (PST)
Message-ID: <20071224.211845.192499191.davem@davemloft.net>
References: <20071221.205407.165162566.davem@davemloft.net>
	<1198308172.4895.11.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1198308172.4895.11.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date: Fri, 21 Dec 2007 23:22:52 -0800

> On Fri, 2007-12-21 at 20:54 -0800, David Miller wrote:
> > [WEXT]: Extract standard call iw_point handling into seperate function.
> 
> This potentially does copy_from_user twice,
> first to the stack, second to a kmalloc'ed area.
> Perhaps it's better to kmalloc first and copy once?

I'm preserving existing behavior in these changes,
feel free to make these kinds of improvements as
a follow-on changeset.
