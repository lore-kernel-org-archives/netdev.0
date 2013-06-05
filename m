From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] usbnet: improve/fix status interrupt endpoint interval
Date: Wed, 05 Jun 2013 08:06:05 +0200
Message-ID: <7493213.1jnuhRJXML@linux-5eaq.site>
References: <20130604182830.GA13186@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	OndrejZary <linux@rainbow-software.org>,
	Ming Lei <ming.lei@canonical.com>
To: Andreas Mohr <andi@lisas.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130604182830.GA13186@rhlx01.hs-esslingen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 04 June 2013 20:28:30 Andreas Mohr wrote:
> 
> From 307685fe8e6dfc8181e30167b9c31479332cb22f Mon Sep 17 00:00:00 2001
> From: Andreas Mohr <andim2@users.sourceforge.net>
> Date: Sun, 2 Jun 2013 20:37:05 +0200
> Subject: [PATCH] usbnet: improve/fix status interrupt endpoint interval
>  tweaking.
> 
> - failed to take super-speed into account
> - <= full-speed seems to have wrong value (specified as frames [ms],
>   thus 3 is not suitable to achieve 8ms)
>   Value 8 now managed to reduce powertop wakeups from ~ 540 to ~ 155
> - add detailed docs and question marks about current practice
> ---
>  drivers/net/usb/usbnet.c |   17 ++++++++++++++++-
>  1 file changed, 16 insertions(+), 1 deletion(-)
> 
> 
> Found this with MCS7830 on a full-speed USB 1.1 port (Inspiron 8000).
> Good to have a rusty notebook with noisy PSU coils, else it would
> have taken a lot longer to nail it ;)
> Tested on -rc4, checkpath.pl:d.
> 
> Signed-off-by: Andreas Mohr <andim2@users.sourceforge.net>
Acked-by: Oliver Neukum <oliver@neukum.org>
