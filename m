From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 0/4] irda: move it to drivers/staging so we can delete it
Date: Sun, 27 Aug 2017 17:03:30 +0200
Message-ID: <20170827150334.32495-1-gregkh@linuxfoundation.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@driverdev.osuosl.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: davem@davemloft.net, samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IRDA code has long been obsolete and broken.  So, to keep people
from trying to use it, and to prevent people from having to maintain it,
let's move it to drivers/staging/ so that we can delete it entirely from
the kernel in a few releases.


Greg Kroah-Hartman (4):
  irda: move net/irda/ to drivers/staging/irda/net/
  irda: move drivers/net/irda to drivers/staging/irda/drivers
  irda: move include/net/irda into staging subdirectory
  staging: irda: add a TODO file.

 drivers/net/Makefile                                              | 1 -
 drivers/staging/Kconfig                                           | 2 ++
 drivers/staging/Makefile                                          | 2 ++
 drivers/staging/irda/TODO                                         | 4 ++++
 drivers/{net/irda => staging/irda/drivers}/Kconfig                | 0
 drivers/{net/irda => staging/irda/drivers}/Makefile               | 2 ++
 drivers/{net/irda => staging/irda/drivers}/act200l-sir.c          | 0
 drivers/{net/irda => staging/irda/drivers}/actisys-sir.c          | 0
 drivers/{net/irda => staging/irda/drivers}/ali-ircc.c             | 0
 drivers/{net/irda => staging/irda/drivers}/ali-ircc.h             | 0
 drivers/{net/irda => staging/irda/drivers}/au1k_ir.c              | 0
 drivers/{net/irda => staging/irda/drivers}/bfin_sir.c             | 0
 drivers/{net/irda => staging/irda/drivers}/bfin_sir.h             | 0
 drivers/{net/irda => staging/irda/drivers}/donauboe.c             | 0
 drivers/{net/irda => staging/irda/drivers}/donauboe.h             | 0
 drivers/{net/irda => staging/irda/drivers}/esi-sir.c              | 0
 drivers/{net/irda => staging/irda/drivers}/girbil-sir.c           | 0
 drivers/{net/irda => staging/irda/drivers}/irda-usb.c             | 0
 drivers/{net/irda => staging/irda/drivers}/irda-usb.h             | 0
 drivers/{net/irda => staging/irda/drivers}/irtty-sir.c            | 0
 drivers/{net/irda => staging/irda/drivers}/irtty-sir.h            | 0
 drivers/{net/irda => staging/irda/drivers}/kingsun-sir.c          | 0
 drivers/{net/irda => staging/irda/drivers}/ks959-sir.c            | 0
 drivers/{net/irda => staging/irda/drivers}/ksdazzle-sir.c         | 0
 drivers/{net/irda => staging/irda/drivers}/litelink-sir.c         | 0
 drivers/{net/irda => staging/irda/drivers}/ma600-sir.c            | 0
 drivers/{net/irda => staging/irda/drivers}/mcp2120-sir.c          | 0
 drivers/{net/irda => staging/irda/drivers}/mcs7780.c              | 0
 drivers/{net/irda => staging/irda/drivers}/mcs7780.h              | 0
 drivers/{net/irda => staging/irda/drivers}/nsc-ircc.c             | 0
 drivers/{net/irda => staging/irda/drivers}/nsc-ircc.h             | 0
 drivers/{net/irda => staging/irda/drivers}/old_belkin-sir.c       | 0
 drivers/{net/irda => staging/irda/drivers}/pxaficp_ir.c           | 0
 drivers/{net/irda => staging/irda/drivers}/sa1100_ir.c            | 0
 drivers/{net/irda => staging/irda/drivers}/sh_sir.c               | 0
 drivers/{net/irda => staging/irda/drivers}/sir-dev.h              | 0
 drivers/{net/irda => staging/irda/drivers}/sir_dev.c              | 0
 drivers/{net/irda => staging/irda/drivers}/sir_dongle.c           | 0
 drivers/{net/irda => staging/irda/drivers}/smsc-ircc2.c           | 0
 drivers/{net/irda => staging/irda/drivers}/smsc-ircc2.h           | 0
 drivers/{net/irda => staging/irda/drivers}/smsc-sio.h             | 0
 drivers/{net/irda => staging/irda/drivers}/stir4200.c             | 0
 drivers/{net/irda => staging/irda/drivers}/tekram-sir.c           | 0
 drivers/{net/irda => staging/irda/drivers}/toim3232-sir.c         | 0
 drivers/{net/irda => staging/irda/drivers}/via-ircc.c             | 0
 drivers/{net/irda => staging/irda/drivers}/via-ircc.h             | 0
 drivers/{net/irda => staging/irda/drivers}/vlsi_ir.c              | 0
 drivers/{net/irda => staging/irda/drivers}/vlsi_ir.h              | 0
 drivers/{net/irda => staging/irda/drivers}/w83977af.h             | 0
 drivers/{net/irda => staging/irda/drivers}/w83977af_ir.c          | 0
 drivers/{net/irda => staging/irda/drivers}/w83977af_ir.h          | 0
 {include => drivers/staging/irda/include}/net/irda/af_irda.h      | 0
 {include => drivers/staging/irda/include}/net/irda/crc.h          | 0
 {include => drivers/staging/irda/include}/net/irda/discovery.h    | 0
 {include => drivers/staging/irda/include}/net/irda/ircomm_core.h  | 0
 {include => drivers/staging/irda/include}/net/irda/ircomm_event.h | 0
 {include => drivers/staging/irda/include}/net/irda/ircomm_lmp.h   | 0
 {include => drivers/staging/irda/include}/net/irda/ircomm_param.h | 0
 {include => drivers/staging/irda/include}/net/irda/ircomm_ttp.h   | 0
 {include => drivers/staging/irda/include}/net/irda/ircomm_tty.h   | 0
 .../staging/irda/include}/net/irda/ircomm_tty_attach.h            | 0
 {include => drivers/staging/irda/include}/net/irda/irda.h         | 0
 {include => drivers/staging/irda/include}/net/irda/irda_device.h  | 0
 {include => drivers/staging/irda/include}/net/irda/iriap.h        | 0
 {include => drivers/staging/irda/include}/net/irda/iriap_event.h  | 0
 {include => drivers/staging/irda/include}/net/irda/irias_object.h | 0
 {include => drivers/staging/irda/include}/net/irda/irlan_client.h | 0
 {include => drivers/staging/irda/include}/net/irda/irlan_common.h | 0
 {include => drivers/staging/irda/include}/net/irda/irlan_eth.h    | 0
 {include => drivers/staging/irda/include}/net/irda/irlan_event.h  | 0
 {include => drivers/staging/irda/include}/net/irda/irlan_filter.h | 0
 .../staging/irda/include}/net/irda/irlan_provider.h               | 0
 {include => drivers/staging/irda/include}/net/irda/irlap.h        | 0
 {include => drivers/staging/irda/include}/net/irda/irlap_event.h  | 0
 {include => drivers/staging/irda/include}/net/irda/irlap_frame.h  | 0
 {include => drivers/staging/irda/include}/net/irda/irlmp.h        | 0
 {include => drivers/staging/irda/include}/net/irda/irlmp_event.h  | 0
 {include => drivers/staging/irda/include}/net/irda/irlmp_frame.h  | 0
 {include => drivers/staging/irda/include}/net/irda/irmod.h        | 0
 {include => drivers/staging/irda/include}/net/irda/irqueue.h      | 0
 {include => drivers/staging/irda/include}/net/irda/irttp.h        | 0
 {include => drivers/staging/irda/include}/net/irda/parameters.h   | 0
 {include => drivers/staging/irda/include}/net/irda/qos.h          | 0
 {include => drivers/staging/irda/include}/net/irda/timer.h        | 0
 {include => drivers/staging/irda/include}/net/irda/wrapper.h      | 0
 {net/irda => drivers/staging/irda/net}/Kconfig                    | 8 ++++----
 {net/irda => drivers/staging/irda/net}/Makefile                   | 2 ++
 {net/irda => drivers/staging/irda/net}/af_irda.c                  | 0
 {net/irda => drivers/staging/irda/net}/discovery.c                | 0
 {net/irda => drivers/staging/irda/net}/ircomm/Kconfig             | 0
 {net/irda => drivers/staging/irda/net}/ircomm/Makefile            | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_core.c       | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_event.c      | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_lmp.c        | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_param.c      | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_ttp.c        | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty.c        | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty_attach.c | 0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty_ioctl.c  | 0
 {net/irda => drivers/staging/irda/net}/irda_device.c              | 0
 {net/irda => drivers/staging/irda/net}/iriap.c                    | 0
 {net/irda => drivers/staging/irda/net}/iriap_event.c              | 0
 {net/irda => drivers/staging/irda/net}/irias_object.c             | 0
 {net/irda => drivers/staging/irda/net}/irlan/Kconfig              | 0
 {net/irda => drivers/staging/irda/net}/irlan/Makefile             | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_client.c       | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_client_event.c | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_common.c       | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_eth.c          | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_event.c        | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_filter.c       | 0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_provider.c     | 0
 .../staging/irda/net}/irlan/irlan_provider_event.c                | 0
 {net/irda => drivers/staging/irda/net}/irlap.c                    | 0
 {net/irda => drivers/staging/irda/net}/irlap_event.c              | 0
 {net/irda => drivers/staging/irda/net}/irlap_frame.c              | 0
 {net/irda => drivers/staging/irda/net}/irlmp.c                    | 0
 {net/irda => drivers/staging/irda/net}/irlmp_event.c              | 0
 {net/irda => drivers/staging/irda/net}/irlmp_frame.c              | 0
 {net/irda => drivers/staging/irda/net}/irmod.c                    | 0
 {net/irda => drivers/staging/irda/net}/irnet/Kconfig              | 0
 {net/irda => drivers/staging/irda/net}/irnet/Makefile             | 0
 {net/irda => drivers/staging/irda/net}/irnet/irnet.h              | 0
 {net/irda => drivers/staging/irda/net}/irnet/irnet_irda.c         | 0
 {net/irda => drivers/staging/irda/net}/irnet/irnet_irda.h         | 0
 {net/irda => drivers/staging/irda/net}/irnet/irnet_ppp.c          | 0
 {net/irda => drivers/staging/irda/net}/irnet/irnet_ppp.h          | 0
 {net/irda => drivers/staging/irda/net}/irnetlink.c                | 0
 {net/irda => drivers/staging/irda/net}/irproc.c                   | 0
 {net/irda => drivers/staging/irda/net}/irqueue.c                  | 0
 {net/irda => drivers/staging/irda/net}/irsysctl.c                 | 0
 {net/irda => drivers/staging/irda/net}/irttp.c                    | 0
 {net/irda => drivers/staging/irda/net}/parameters.c               | 0
 {net/irda => drivers/staging/irda/net}/qos.c                      | 0
 {net/irda => drivers/staging/irda/net}/timer.c                    | 0
 {net/irda => drivers/staging/irda/net}/wrapper.c                  | 0
 net/Kconfig                                                       | 1 -
 net/Makefile                                                      | 1 -
 138 files changed, 16 insertions(+), 7 deletions(-)
 create mode 100644 drivers/staging/irda/TODO
 rename drivers/{net/irda => staging/irda/drivers}/Kconfig (100%)
 rename drivers/{net/irda => staging/irda/drivers}/Makefile (96%)
 rename drivers/{net/irda => staging/irda/drivers}/act200l-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/actisys-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/ali-ircc.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/ali-ircc.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/au1k_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/bfin_sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/bfin_sir.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/donauboe.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/donauboe.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/esi-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/girbil-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/irda-usb.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/irda-usb.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/irtty-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/irtty-sir.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/kingsun-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/ks959-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/ksdazzle-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/litelink-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/ma600-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/mcp2120-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/mcs7780.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/mcs7780.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/nsc-ircc.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/nsc-ircc.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/old_belkin-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/pxaficp_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sa1100_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sh_sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sir-dev.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sir_dev.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sir_dongle.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/smsc-ircc2.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/smsc-ircc2.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/smsc-sio.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/stir4200.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/tekram-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/toim3232-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/via-ircc.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/via-ircc.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/vlsi_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/vlsi_ir.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/w83977af.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/w83977af_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/w83977af_ir.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/af_irda.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/crc.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/discovery.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_core.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_lmp.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_param.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_ttp.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_tty.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_tty_attach.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irda.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irda_device.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/iriap.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/iriap_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irias_object.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_client.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_common.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_eth.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_filter.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_provider.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlap.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlap_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlap_frame.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlmp.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlmp_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlmp_frame.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irmod.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irqueue.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irttp.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/parameters.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/qos.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/timer.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/wrapper.h (100%)
 rename {net/irda => drivers/staging/irda/net}/Kconfig (94%)
 rename {net/irda => drivers/staging/irda/net}/Makefile (88%)
 rename {net/irda => drivers/staging/irda/net}/af_irda.c (100%)
 rename {net/irda => drivers/staging/irda/net}/discovery.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/Kconfig (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/Makefile (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_core.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_lmp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_param.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_ttp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty_attach.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty_ioctl.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irda_device.c (100%)
 rename {net/irda => drivers/staging/irda/net}/iriap.c (100%)
 rename {net/irda => drivers/staging/irda/net}/iriap_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irias_object.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/Kconfig (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/Makefile (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_client.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_client_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_common.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_eth.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_filter.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_provider.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_provider_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlap.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlap_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlap_frame.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlmp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlmp_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlmp_frame.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irmod.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/Kconfig (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/Makefile (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet.h (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet_irda.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet_irda.h (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet_ppp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet_ppp.h (100%)
 rename {net/irda => drivers/staging/irda/net}/irnetlink.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irproc.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irqueue.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irsysctl.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irttp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/parameters.c (100%)
 rename {net/irda => drivers/staging/irda/net}/qos.c (100%)
 rename {net/irda => drivers/staging/irda/net}/timer.c (100%)
 rename {net/irda => drivers/staging/irda/net}/wrapper.c (100%)

-- 
2.14.1
