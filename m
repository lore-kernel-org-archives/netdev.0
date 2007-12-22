From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [WEXT 3/12]: Extract standard call iw_point handling into
	seperate function.
Date: Fri, 21 Dec 2007 23:22:52 -0800
Message-ID: <1198308172.4895.11.camel@localhost>
References: <20071221.205407.165162566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071221.205407.165162566.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-12-21 at 20:54 -0800, David Miller wrote:
> [WEXT]: Extract standard call iw_point handling into seperate function.

This potentially does copy_from_user twice,
first to the stack, second to a kmalloc'ed area.
Perhaps it's better to kmalloc first and copy once?
