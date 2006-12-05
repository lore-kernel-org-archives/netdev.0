From: Karsten Keil <kkeil@suse.de>
Subject: Re: [PATCH 5/9] pcmcia: conf.ConfigBase and conf.Present consolidation
Date: Wed, 6 Dec 2006 00:36:19 +0100
Message-ID: <20061205233618.GB31463@pingi.kke.suse.de>
References: <20061205015942.GA2624@dominikbrodowski.de> <20061205021716.GF2624@dominikbrodowski.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-scsi-owner@vger.kernel.org>
To: linux-pcmcia@lists.infradead.org, alan@lxorguk.ukuu.org.uk,
	bluez-devel@lists.sf.net, isdn4linux@listserv.isdn4linux.de,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-parport@lists.infradead.org,
	linux-usb-devel@lists.sourceforge.net, laforge@gnumonks.org
Content-Disposition: inline
In-Reply-To: <20061205021716.GF2624@dominikbrodowski.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 04, 2006 at 09:17:16PM -0500, Dominik Brodowski wrote:
> From: Dominik Brodowski <linux@dominikbrodowski.net>
> Date: Wed, 25 Oct 2006 21:49:27 -0400
> Subject: [PATCH] pcmcia: conf.ConfigBase and conf.Present consolidation
> 
> struct pcmcia_device *p_dev->conf.ConfigBase and .Present are set in almost
> all PCMICA driver right at the beginning, using the same calls but slightly
> different implementations. Unfiy this in the PCMCIA core.
> 
> Includes a small bugfix ("drivers/net/pcmcia/xirc2ps_cs.c: remove unused
> label") from and Signed-off-by Adrian Bunk <bunk@stusta.de>
> 
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> ---
>  drivers/ata/pata_pcmcia.c               |    7 -----
>  drivers/bluetooth/bluecard_cs.c         |   38 +------------------------------
>  drivers/bluetooth/bt3c_cs.c             |   20 +---------------
>  drivers/bluetooth/btuart_cs.c           |   20 +---------------
>  drivers/bluetooth/dtl1_cs.c             |   20 +---------------
>  drivers/char/pcmcia/cm4000_cs.c         |   20 ----------------
>  drivers/char/pcmcia/cm4040_cs.c         |   20 ----------------
>  drivers/char/pcmcia/synclink_cs.c       |    7 -----
>  drivers/ide/legacy/ide-cs.c             |    6 -----


>  drivers/isdn/hardware/avm/avm_cs.c      |   22 ------------------
>  drivers/isdn/hisax/avma1_cs.c           |   22 ------------------
>  drivers/isdn/hisax/elsa_cs.c            |   17 -------------
>  drivers/isdn/hisax/sedlbauer_cs.c       |   10 --------
>  drivers/isdn/hisax/teles_cs.c           |   17 -------------

Acked-by: Karsten Keil <kkeil@suse.de>
for ISDN.

...

-- 
Karsten Keil
SuSE Labs
ISDN development
