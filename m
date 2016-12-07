From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [patch] ser_gigaset: return -ENOMEM on error instead of success
Date: Wed, 07 Dec 2016 20:06:23 +0100
Message-ID: <1481137583.12596.19.camel@tiscali.nl>
References: <20161207112203.GC5507@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Tilman Schmidt <tilman@imap.cc>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20161207112203.GC5507@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-12-07 at 14:22 +0300, Dan Carpenter wrote:
> If we can't allocate the resources in gigaset_initdriver() then we
> should return -ENOMEM instead of zero.

That's entirely correct.

> Fixes: 2869b23e4b95 ("[PATCH] drivers/isdn/gigaset: new M101 driver (v2)")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> Ancient code.

For ancient hardware.

I'll be back (probably tomorrow) after a short test to see whether this really
needs to go into stable. It almost certainly should, but I'd like to first see
the mess the current code leaves behind once gigaset_initdriver() fails before
saying so.

Thanks for reporting this!


Paul Bolle
