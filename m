From: "David S. Miller" <davem@redhat.com>
Subject: Re: Restrict local IP announcements in ARP requests
Date: Mon, 9 Feb 2004 14:08:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209140853.69ab8bea.davem@redhat.com>
References: <Pine.LNX.4.58.0402081149001.6268@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402081149001.6268@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 8 Feb 2004 11:59:35 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> 	I'm proposing simple flag that controls the src selection
> in our ARP requests. I named it arp_announce - mode used to define
> different restriction levels for announcing the local source address
> from IP packets in ARP requests:

I'm fine with this patch, although it appears incomplete because:

> 2 - always use the best source address for this target

The code handling this case is "#if 0/#endif" commented out in your
patch.

Finish this thing up, and as a birthday present to everyone I'll also
add an IN_DEV_ARP_IGNORE flag for inet devices to so people can control
complete ARP ignoring via a global/per-device sysctl.

Hopefully, combined, this will get all the virtual server maniacs off
of my back :-)
