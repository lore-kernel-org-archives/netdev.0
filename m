From: Roman Kagan <rkagan@mail.ru>
Subject: Re: [Linux-ATM-General] [RFC][PATCH] Very basic sysfs support for ATM devices (updated)
Date: Mon, 7 Feb 2005 12:45:18 +0300
Message-ID: <20050207094517.GC2360@katya>
References: <20050121085123.GA2471@katya> <200502041811.j14IBOna020338@ginger.cmf.nrl.navy.mil> <20050204201327.GA2439@katya> <200502071003.09211.duncan.sands@math.u-psud.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: usbatm@lists.infradead.org, netdev@oss.sgi.com,
        linux-atm-general@lists.sourceforge.net
Content-Disposition: inline
In-Reply-To: <200502071003.09211.duncan.sands@math.u-psud.fr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Feb 07, 2005 at 10:03:08AM +0100, Duncan Sands wrote:
> this is a long-standing problem with ATM device initialisation: the device
> becomes available before the struct atm_dev is initialised!
> [...]
> In the past, this race was only a theoretical
> problem for SMP machines; but with your patch it hits everyone.

Indeed.  OTOH at a first glance splitting the ATM device initialisation
API into allocation and registration doesn't look a terribly difficult
thing, it would require fairly local changes in the drivers.

Unless Chas' move to struct net_device is alredy knocking on the door,
of course.

Cheers,
  Roman.
