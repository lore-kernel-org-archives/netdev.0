From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH V2 2/3] bluetooth: Convert BT_ERR/BT_INFO to
 bt_err/bt_info
Date: Fri, 17 Feb 2012 09:40:18 +0100
Message-ID: <1329468018.28848.133.camel@aeonflux>
References: <cover.1329461202.git.joe@perches.com>
	 <6737e9dc6d2528f9c94c122709a40e4c23c9477a.1329461203.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6737e9dc6d2528f9c94c122709a40e4c23c9477a.1329461203.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

> Use the more common kernel style functions rather than
> an upper case macro.
> 
> Add newlines to end of formats.
> Coalesce formats, align arguments.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/bluetooth/ath3k.c          |   46 +++++++-------
>  drivers/bluetooth/bcm203x.c        |   24 ++++----
>  drivers/bluetooth/bfusb.c          |   67 +++++++++++---------
>  drivers/bluetooth/bluecard_cs.c    |   17 +++---
>  drivers/bluetooth/bpa10x.c         |   18 +++---
>  drivers/bluetooth/bt3c_cs.c        |   36 ++++++-----
>  drivers/bluetooth/btmrvl_debugfs.c |    2 +-
>  drivers/bluetooth/btmrvl_main.c    |   39 ++++++------
>  drivers/bluetooth/btmrvl_sdio.c    |  122 +++++++++++++++++-------------------
>  drivers/bluetooth/btsdio.c         |    2 +-
>  drivers/bluetooth/btuart_cs.c      |   23 ++++---
>  drivers/bluetooth/btusb.c          |   38 ++++++------
>  drivers/bluetooth/btwilink.c       |   29 ++++-----
>  drivers/bluetooth/dtl1_cs.c        |   19 +++---
>  drivers/bluetooth/hci_ath.c        |    6 +-
>  drivers/bluetooth/hci_bcsp.c       |   50 ++++++++-------
>  drivers/bluetooth/hci_h4.c         |    8 +-
>  drivers/bluetooth/hci_ldisc.c      |   14 ++--
>  drivers/bluetooth/hci_ll.c         |   33 ++++++----
>  drivers/bluetooth/hci_vhci.c       |    6 +-
>  include/net/bluetooth/hci_core.h   |    6 +-
>  net/bluetooth/af_bluetooth.c       |    4 +-
>  net/bluetooth/bnep/core.c          |    4 +-
>  net/bluetooth/bnep/netdev.c        |    2 +-
>  net/bluetooth/bnep/sock.c          |    4 +-
>  net/bluetooth/cmtp/capi.c          |   19 +++---
>  net/bluetooth/cmtp/core.c          |    8 +-
>  net/bluetooth/cmtp/sock.c          |    4 +-
>  net/bluetooth/hci_core.c           |   24 ++++----
>  net/bluetooth/hci_event.c          |   16 +++---
>  net/bluetooth/hci_sock.c           |    6 +-
>  net/bluetooth/hci_sysfs.c          |    2 +-
>  net/bluetooth/hidp/core.c          |   14 +++--
>  net/bluetooth/hidp/sock.c          |    4 +-
>  net/bluetooth/l2cap_core.c         |   32 +++++-----
>  net/bluetooth/l2cap_sock.c         |    6 +-
>  net/bluetooth/mgmt.c               |    6 +-
>  net/bluetooth/rfcomm/core.c        |   16 +++---
>  net/bluetooth/rfcomm/sock.c        |    8 +-
>  net/bluetooth/rfcomm/tty.c         |   18 +++---
>  net/bluetooth/sco.c                |    8 +-
>  net/bluetooth/smp.c                |   14 ++--
>  42 files changed, 419 insertions(+), 405 deletions(-)

I leave this up to Johan if he can get it merged without having to redo
the patch. Otherwise it might have to wait a little bit.

If you would split drivers/ from include/ and net/ I think it has more
likelihood that at least that one can be merged easily.

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel
