From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Re: [PATCH 07/15] pcmcia: move config_{base,index,regs} to struct
 pcmcia_device
Date: Fri, 3 Sep 2010 19:32:56 -0300
Message-ID: <20100903223256.GC16973@vigoh>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
 <1283511434-21620-7-git-send-email-linux@dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pcmcia@lists.infradead.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-ide@vger.kernel.org,
	linux-usb@vger.kernel.org, laforge@gnumonks.org,
	linux-mtd@lists.infradead.org, linux-bluetooth@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-serial@vger.kernel.org,
	Jiri Kosina <jkosina@suse.cz>, linux-scsi@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1283511434-21620-7-git-send-email-linux@dominikbrodowski.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Dominik Brodowski <linux@dominikbrodowski.net> [2010-09-03 12:57:06 +0200]:

> Several drivers prefer to explicitly set config_{base,index,regs},
> formerly known as ConfigBase, ConfigIndex and Present. Instead of
> passing these values inside config_req_t, store it in struct
> pcmcia_device.
> 
> CC: netdev@vger.kernel.org
> CC: linux-wireless@vger.kernel.org
> CC: linux-ide@vger.kernel.org
> CC: linux-usb@vger.kernel.org
> CC: laforge@gnumonks.org
> CC: linux-mtd@lists.infradead.org
> CC: linux-bluetooth@vger.kernel.org
> CC: alsa-devel@alsa-project.org
> CC: linux-serial@vger.kernel.org
> CC: Jiri Kosina <jkosina@suse.cz>
> CC: linux-scsi@vger.kernel.org
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> ---
>  drivers/bluetooth/bluecard_cs.c                  |    2 +-
>  drivers/char/pcmcia/ipwireless/main.c            |    2 +-
>  drivers/char/pcmcia/synclink_cs.c                |    6 ++--
>  drivers/ide/ide-cs.c                             |    3 +-
>  drivers/isdn/hardware/avm/avm_cs.c               |    4 +-
>  drivers/isdn/hisax/avma1_cs.c                    |    4 +-
>  drivers/isdn/hisax/elsa_cs.c                     |    2 +-
>  drivers/isdn/hisax/sedlbauer_cs.c                |    2 +-
>  drivers/isdn/hisax/teles_cs.c                    |    2 +-
>  drivers/mtd/maps/pcmciamtd.c                     |    2 +-
>  drivers/net/pcmcia/3c574_cs.c                    |    2 +-
>  drivers/net/pcmcia/3c589_cs.c                    |    2 +-
>  drivers/net/pcmcia/axnet_cs.c                    |    6 ++--
>  drivers/net/pcmcia/fmvj18x_cs.c                  |   22 ++++++------
>  drivers/net/pcmcia/ibmtr_cs.c                    |    4 +-
>  drivers/net/pcmcia/nmclan_cs.c                   |    4 +-
>  drivers/net/pcmcia/pcnet_cs.c                    |    6 ++--
>  drivers/net/pcmcia/smc91c92_cs.c                 |   10 +++---
>  drivers/net/pcmcia/xirc2ps_cs.c                  |    2 +-
>  drivers/net/wireless/airo_cs.c                   |    2 +-
>  drivers/net/wireless/hostap/hostap_cs.c          |    2 +-
>  drivers/net/wireless/ray_cs.c                    |    2 +-
>  drivers/net/wireless/wl3501_cs.c                 |    2 +-
>  drivers/parport/parport_cs.c                     |    2 +-
>  drivers/pcmcia/cs_internal.h                     |    3 --
>  drivers/pcmcia/ds.c                              |    8 ++--
>  drivers/pcmcia/pcmcia_cis.c                      |    2 +-
>  drivers/pcmcia/pcmcia_resource.c                 |   38 +++++++++++-----------
>  drivers/scsi/pcmcia/aha152x_stub.c               |    2 +-
>  drivers/scsi/pcmcia/fdomain_stub.c               |    2 +-
>  drivers/scsi/pcmcia/nsp_cs.c                     |    2 +-
>  drivers/scsi/pcmcia/qlogic_stub.c                |    2 +-
>  drivers/serial/serial_cs.c                       |    6 ++--
>  drivers/staging/comedi/drivers/cb_das16_cs.c     |    2 +-
>  drivers/staging/comedi/drivers/das08_cs.c        |    2 +-
>  drivers/staging/comedi/drivers/ni_daq_700.c      |    2 +-
>  drivers/staging/comedi/drivers/ni_daq_dio24.c    |    2 +-
>  drivers/staging/comedi/drivers/ni_labpc_cs.c     |    2 +-
>  drivers/staging/comedi/drivers/quatech_daqp_cs.c |    2 +-
>  drivers/staging/wlags49_h2/wl_cs.c               |    4 +-
>  drivers/usb/host/sl811_cs.c                      |    2 +-
>  include/pcmcia/cs.h                              |   15 --------
>  include/pcmcia/ds.h                              |   14 ++++++++
>  sound/pcmcia/pdaudiocf/pdaudiocf.c               |    6 ++--
>  sound/pcmcia/vx/vxpocket.c                       |    4 +-
>  45 files changed, 107 insertions(+), 112 deletions(-)

For drivers/bluetooth

Acked-by: Gustavo F. Padovan <padovan@profusion.mobi>

-- 
Gustavo F. Padovan
ProFUSION embedded systems - http://profusion.mobi
