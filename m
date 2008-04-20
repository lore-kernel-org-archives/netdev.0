From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [patch 2/3] hci_usb: remove code obfuscation
Date: Sat, 19 Apr 2008 18:16:59 -0700 (PDT)
Message-ID: <20080419.181659.97930825.davem@davemloft.net>
References: <200804182046.m3IKks86014628@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	pavel-+ZI9xUNit7I@public.gmane.org, pavel-AlSwsSmVLrQ@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200804182046.m3IKks86014628-AB4EexQrvXRQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Date: Fri, 18 Apr 2008 13:46:53 -0700

> _urb_free is an alias for kfree... making code longer & harder to
> read. Remove it.
> 
> Signed-off-by: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
> Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
> Cc: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

As long as the code is in the tree, we should accept
simplifications that aid to code understanding.

Marking drivers broken or deprecated or to-be-replaced is
a secondary concern.

Therefore I'm applying this patch, thanks Pavel.
