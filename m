From: rask@sygehus.dk (Rask Ingemann Lambertsen)
Subject: Is a driver allowed to modify dev->flags?
Date: Tue, 1 Apr 2003 18:49:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3100.13188650391$1049216161@news.gmane.org>
Reply-To: rask@sygehus.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi.

Is a network device driver allowed to modify dev->flags? For example:

if (dev->flags & IFF_ALLMULTI)
        dev->flags |= IFF_PROMISC;

I've found it to cause the IFF_PROMISC flag to stick when using "tcpdump -p", which to my surprice sets the IFF_ALLMULTI flag.

Regards,
Rask Ingemann Lambertsen
