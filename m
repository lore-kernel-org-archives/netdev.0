From: rask@sygehus.dk (Rask Ingemann Lambertsen)
Subject: Re: Must dev->set_multicast_list() complete before returning?
Date: Wed, 2 Apr 2003 15:09:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5893.16517948664$1049291483@news.gmane.org>
References: <Pine.LNX.4.44.0304012242360.1685-100000@beohost.scyld.com>
Reply-To: rask@sygehus.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Donald Becker wrote:

> The promiscuous setting must complete before return, but there are
> several drivers where the updated multicast filter does not immediately
> take effect.
> 
> I have not seen hardware where setting promiscuous mode is a queued
> command.

Intel i82586, i82596 and, as far as I can tell from other drivers, several other Intel i825xx Ethernet chips. IIRC, the function must not sleep. That means busy-wait for it to complete. :-(

Regards,
Rask Ingemann Lambertsen
