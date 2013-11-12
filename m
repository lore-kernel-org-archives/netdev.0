From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: shutdown(3) and bluetooth.
Date: Tue, 12 Nov 2013 16:13:50 -0500 (EST)
Message-ID: <20131112.161350.946584501122269943.davem@davemloft.net>
References: <20131112211125.GA2912@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131112211125.GA2912-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Tue, 12 Nov 2013 16:11:25 -0500

> Is shutdown() allowed to block indefinitely ? The man page doesn't say either way,
> and I've noticed that my fuzz tester occasionally hangs for days spinning in bt_sock_wait_state()
> 
> Is there something I should be doing to guarantee that this operation
> will either time out, or return instantly ?
> 
> In this specific case, I doubt anything is on the "sender" end of the socket, so
> it's going to be waiting forever for a state change that won't arrive.

Adding bluetooth and wireless lists.  Dave, please consult MAINTAINERS when
asking questions like this, thanks!
