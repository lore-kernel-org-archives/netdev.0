From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 6/6] pcmcia: remove cs_types.h
Date: Fri, 23 Jul 2010 08:28:08 -0700
Message-ID: <1279898888.2621.18.camel@localhost.localdomain>
References: <20100723083726.GA20947@comet.dominikbrodowski.net>
	 <1279874305-21191-6-git-send-email-linux@dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-pcmcia@lists.infradead.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-ide@vger.kernel.org,
	linux-usb@vger.kernel.org, laforge@gnumonks.org,
	linux-mtd@lists.infradead.org, linux-bluetooth@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-serial@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <1279874305-21191-6-git-send-email-linux@dominikbrodowski.net>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dominik,

> Remove cs_types.h which is no longer needed: Most definitions aren't
> used at all, a few can be made away with, and two remaining definitions
> (typedefs, unfortunatley) may be moved to more specific places.
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
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> ---
>  Documentation/pcmcia/driver-changes.txt          |    5 +++
>  drivers/ata/pata_pcmcia.c                        |    1 -
>  drivers/bluetooth/bluecard_cs.c                  |    1 -
>  drivers/bluetooth/bt3c_cs.c                      |    1 -
>  drivers/bluetooth/btuart_cs.c                    |    1 -
>  drivers/bluetooth/dtl1_cs.c                      |    1 -
>  drivers/char/pcmcia/cm4000_cs.c                  |    1 -
>  drivers/char/pcmcia/cm4040_cs.c                  |    1 -
>  drivers/char/pcmcia/ipwireless/main.h            |    1 -
>  drivers/char/pcmcia/ipwireless/tty.h             |    1 -
>  drivers/char/pcmcia/synclink_cs.c                |    1 -
>  drivers/ide/ide-cs.c                             |    1 -
>  drivers/isdn/hardware/avm/avm_cs.c               |    1 -
>  drivers/isdn/hisax/avma1_cs.c                    |    1 -
>  drivers/isdn/hisax/elsa_cs.c                     |    1 -
>  drivers/isdn/hisax/sedlbauer_cs.c                |    1 -
>  drivers/isdn/hisax/teles_cs.c                    |    1 -
>  drivers/mmc/host/sdricoh_cs.c                    |    1 -
>  drivers/mtd/maps/pcmciamtd.c                     |    1 -
>  drivers/net/pcmcia/3c574_cs.c                    |    1 -
>  drivers/net/pcmcia/3c589_cs.c                    |    1 -
>  drivers/net/pcmcia/axnet_cs.c                    |    1 -
>  drivers/net/pcmcia/com20020_cs.c                 |    1 -
>  drivers/net/pcmcia/fmvj18x_cs.c                  |    1 -
>  drivers/net/pcmcia/ibmtr_cs.c                    |    1 -
>  drivers/net/pcmcia/nmclan_cs.c                   |    1 -
>  drivers/net/pcmcia/pcnet_cs.c                    |    5 +--
>  drivers/net/pcmcia/smc91c92_cs.c                 |    1 -
>  drivers/net/pcmcia/xirc2ps_cs.c                  |    1 -
>  drivers/net/wireless/airo_cs.c                   |    1 -
>  drivers/net/wireless/atmel_cs.c                  |    1 -
>  drivers/net/wireless/b43/pcmcia.c                |    1 -
>  drivers/net/wireless/hostap/hostap_cs.c          |    3 +-
>  drivers/net/wireless/libertas/if_cs.c            |    1 -
>  drivers/net/wireless/orinoco/orinoco_cs.c        |    1 -
>  drivers/net/wireless/orinoco/spectrum_cs.c       |    1 -
>  drivers/net/wireless/ray_cs.c                    |    1 -
>  drivers/net/wireless/wl3501_cs.c                 |   10 +-----
>  drivers/parport/parport_cs.c                     |    1 -
>  drivers/pcmcia/au1000_generic.h                  |    1 -
>  drivers/pcmcia/au1000_pb1x00.c                   |    2 -
>  drivers/pcmcia/cistpl.c                          |    1 -
>  drivers/pcmcia/cs.c                              |    1 -
>  drivers/pcmcia/db1xxx_ss.c                       |    1 -
>  drivers/pcmcia/ds.c                              |    1 -
>  drivers/pcmcia/i82092.c                          |    1 -
>  drivers/pcmcia/i82365.c                          |    1 -
>  drivers/pcmcia/m32r_cfc.c                        |    1 -
>  drivers/pcmcia/m32r_pcc.c                        |    1 -
>  drivers/pcmcia/m8xx_pcmcia.c                     |    1 -
>  drivers/pcmcia/pcmcia_cis.c                      |    1 -
>  drivers/pcmcia/pcmcia_resource.c                 |    1 -
>  drivers/pcmcia/pd6729.c                          |    1 -
>  drivers/pcmcia/pxa2xx_base.c                     |    1 -
>  drivers/pcmcia/rsrc_iodyn.c                      |    1 -
>  drivers/pcmcia/rsrc_mgr.c                        |    1 -
>  drivers/pcmcia/rsrc_nonstatic.c                  |    1 -
>  drivers/pcmcia/sa1100_generic.c                  |    1 -
>  drivers/pcmcia/soc_common.h                      |    1 -
>  drivers/pcmcia/socket_sysfs.c                    |    1 -
>  drivers/pcmcia/tcic.c                            |    1 -
>  drivers/pcmcia/xxs1500_ss.c                      |    1 -
>  drivers/pcmcia/yenta_socket.c                    |    1 -
>  drivers/scsi/pcmcia/aha152x_stub.c               |    1 -
>  drivers/scsi/pcmcia/fdomain_stub.c               |    1 -
>  drivers/scsi/pcmcia/nsp_cs.c                     |    1 -
>  drivers/scsi/pcmcia/qlogic_stub.c                |    1 -
>  drivers/scsi/pcmcia/sym53c500_cs.c               |    1 -
>  drivers/serial/serial_cs.c                       |    1 -
>  drivers/ssb/main.c                               |    1 -
>  drivers/ssb/pcmcia.c                             |    1 -
>  drivers/ssb/scan.c                               |    1 -
>  drivers/staging/comedi/drivers/cb_das16_cs.c     |    1 -
>  drivers/staging/comedi/drivers/das08_cs.c        |    1 -
>  drivers/staging/comedi/drivers/ni_daq_700.c      |    1 -
>  drivers/staging/comedi/drivers/ni_daq_dio24.c    |    1 -
>  drivers/staging/comedi/drivers/ni_labpc_cs.c     |    1 -
>  drivers/staging/comedi/drivers/ni_mio_cs.c       |    1 -
>  drivers/staging/comedi/drivers/quatech_daqp_cs.c |    1 -
>  drivers/staging/wlags49_h2/wl_cs.c               |    1 -
>  drivers/staging/wlags49_h2/wl_internal.h         |    1 -
>  drivers/telephony/ixj_pcmcia.c                   |    1 -
>  drivers/usb/host/sl811_cs.c                      |    5 +--
>  include/pcmcia/cistpl.h                          |    2 +
>  include/pcmcia/cs.h                              |   10 +-----
>  include/pcmcia/cs_types.h                        |   40 ----------------------
>  include/pcmcia/ds.h                              |    3 +-
>  include/pcmcia/ss.h                              |    1 -
>  sound/pcmcia/pdaudiocf/pdaudiocf.h               |    1 -
>  sound/pcmcia/vx/vxpocket.h                       |    1 -
>  90 files changed, 14 insertions(+), 151 deletions(-)
>  delete mode 100644 include/pcmcia/cs_types.h

for drivers/bluetooth/

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel


