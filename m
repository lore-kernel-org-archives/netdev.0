From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Re: [PATCH 03/15] pcmcia: move Vpp setup to struct pcmcia_device
Date: Fri, 3 Sep 2010 19:34:13 -0300
Message-ID: <20100903223413.GD16973@vigoh>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
 <1283511434-21620-3-git-send-email-linux@dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pcmcia@lists.infradead.org, linux-ide@vger.kernel.org,
	netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	linux-mtd@lists.infradead.org, linux-wireless@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1283511434-21620-3-git-send-email-linux@dominikbrodowski.net>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Dominik Brodowski <linux@dominikbrodowski.net> [2010-09-03 12:57:02 +0200]:

> Some drivers prefer to explicitly set Vpp. Instead of passing the
> voltage inside config_req_t, store it in struct pcmcia_device.
> 
> CC: linux-ide@vger.kernel.org
> CC: netdev@vger.kernel.org
> CC: linux-bluetooth@vger.kernel.org
> CC: linux-mtd@lists.infradead.org
> CC: linux-wireless@vger.kernel.org
> CC: linux-serial@vger.kernel.org
> CC: linux-usb@vger.kernel.org
> CC: linux-scsi@vger.kernel.org
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> ---
>  drivers/ata/pata_pcmcia.c                  |    4 ++--
>  drivers/bluetooth/bt3c_cs.c                |    2 +-
>  drivers/bluetooth/btuart_cs.c              |    2 +-
>  drivers/ide/ide-cs.c                       |    6 +++---
>  drivers/isdn/hisax/sedlbauer_cs.c          |    8 ++++----
>  drivers/mtd/maps/pcmciamtd.c               |    4 ++--
>  drivers/net/wireless/airo_cs.c             |    8 ++++----
>  drivers/net/wireless/atmel_cs.c            |    4 ++--
>  drivers/net/wireless/hostap/hostap_cs.c    |   10 +++++-----
>  drivers/net/wireless/orinoco/orinoco_cs.c  |    4 ++--
>  drivers/net/wireless/orinoco/spectrum_cs.c |    4 ++--
>  drivers/pcmcia/pcmcia_resource.c           |    3 ++-
>  drivers/scsi/pcmcia/nsp_cs.c               |    8 ++++----
>  drivers/serial/serial_cs.c                 |    2 +-
>  drivers/usb/host/sl811_cs.c                |    8 ++++----
>  include/pcmcia/cs.h                        |    1 -
>  include/pcmcia/ds.h                        |    1 +
>  17 files changed, 40 insertions(+), 39 deletions(-)

For drivers/bluetooth

Acked-by: Gustavo F. Padovan <padovan@profusion.mobi>

-- 
Gustavo F. Padovan
ProFUSION embedded systems - http://profusion.mobi
