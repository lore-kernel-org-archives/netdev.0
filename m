From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: shutdown(3) and bluetooth.
Date: Wed, 13 Nov 2013 06:56:23 +0900
Message-ID: <DF4C2B40-BD87-4E88-911D-E3E5F488CAE4@holtmann.org>
References: <20131112211125.GA2912@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org development"
	<linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131112211125.GA2912-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> Is shutdown() allowed to block indefinitely ? The man page doesn't say either way,
> and I've noticed that my fuzz tester occasionally hangs for days spinning in bt_sock_wait_state()
> 
> Is there something I should be doing to guarantee that this operation
> will either time out, or return instantly ?
> 
> In this specific case, I doubt anything is on the "sender" end of the socket, so
> it's going to be waiting forever for a state change that won't arrive.

can you give us some extra information here. What kind of Bluetooth socket is this actually. From the top of my head, I have no idea why we would even wait forever. Normally when all low-level links are gone, the socket will shut down anyway.

Regards

Marcel
