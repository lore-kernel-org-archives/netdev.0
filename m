From: rask@sygehus.dk (Rask Ingemann Lambertsen)
Subject: Re:  Is a driver allowed to modify dev->flags?
Date: Wed, 2 Apr 2003 15:01:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <44003.7703760483$1049288519@news.gmane.org>
References: <3e89c32348ce76.94538914@not right>
Reply-To: rask@sygehus.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I wrote: 

> Is a network device driver allowed to modify dev->flags? For example:
> 
> if (dev->flags & IFF_ALLMULTI)
>         dev->flags |= IFF_PROMISC;

Maybe the right question is: Is it necessary for the driver to set the IFF_PROMISC flag if the device enters promiscuous mode because it doesn't support all-multicast mode?

Regards,
Rask Ingemann Lambertsen
