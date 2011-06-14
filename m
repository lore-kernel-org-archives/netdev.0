From: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH] TTY: define TTY_MAX_RECEIVE_ROOM to 65536
Date: Tue, 14 Jun 2011 14:24:46 +0100
Message-ID: <20110614142446.063c0859@bob.linux.org.uk>
References: <1308057986-11472-1-git-send-email-ffainelli@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	Andreas Koensgen <ajk-iz34hMvxm2Hmj42eshorlhS11BummzK+@public.gmane.org>,
	Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Mikael Starvik <starvik-VrBV9hrLPhE@public.gmane.org>,
	Jesper Nilsson <jesper.nilsson-VrBV9hrLPhE@public.gmane.org>,
	Pavan Savoy <pavan_savoy-l0cyMroinI0@public.gmane.org>, Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>,
	Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ppp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <ffainelli-MmRyKUhfbQ9GWvitb5QawA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1308057986-11472-1-git-send-email-ffainelli-MmRyKUhfbQ9GWvitb5QawA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Jun 2011 15:26:25 +0200
Florian Fainelli <ffainelli-MmRyKUhfbQ9GWvitb5QawA@public.gmane.org> wrote:

> A lot of TTY drivers are setting their receive_room value to 65536
> so let's define a constant for this.

These are not all the same thing so NAK

Linus wants to get rid of tty->receive_room anyway
