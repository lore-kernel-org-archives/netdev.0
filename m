From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH V2 3/3] bluetooth: Convert BT_DBG to pr_debug
Date: Fri, 17 Feb 2012 09:42:06 +0100
Message-ID: <1329468126.28848.135.camel@aeonflux>
References: <cover.1329461202.git.joe@perches.com>
	 <6e53178ca0d6ca35c4953e653571d03379759af5.1329461203.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6e53178ca0d6ca35c4953e653571d03379759af5.1329461203.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

> Add "\n" to uses, align arguments, coalesce formats.
> Fix a typo and fix a bad format extended by a line continuation.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/bluetooth/ath3k.c       |   10 +-
>  drivers/bluetooth/bcm203x.c     |   10 +-
>  drivers/bluetooth/bfusb.c       |   35 +++---
>  drivers/bluetooth/bpa10x.c      |   30 ++--
>  drivers/bluetooth/btmrvl_main.c |   63 +++++-----
>  drivers/bluetooth/btmrvl_sdio.c |   27 ++--
>  drivers/bluetooth/btsdio.c      |   24 ++--
>  drivers/bluetooth/btusb.c       |   48 ++++----
>  drivers/bluetooth/btwilink.c    |   17 +--
>  drivers/bluetooth/hci_ath.c     |    8 +-
>  drivers/bluetooth/hci_bcsp.c    |   28 ++--
>  drivers/bluetooth/hci_h4.c      |   10 +-
>  drivers/bluetooth/hci_ldisc.c   |   23 ++--
>  drivers/bluetooth/hci_ll.c      |   50 ++++----
>  include/net/bluetooth/l2cap.h   |    2 +-
>  net/bluetooth/af_bluetooth.c    |   16 +-
>  net/bluetooth/bnep/core.c       |   26 ++--
>  net/bluetooth/bnep/netdev.c     |   12 +-
>  net/bluetooth/bnep/sock.c       |    6 +-
>  net/bluetooth/cmtp/capi.c       |   31 +++--
>  net/bluetooth/cmtp/core.c       |   23 ++--
>  net/bluetooth/cmtp/sock.c       |    6 +-
>  net/bluetooth/hci_conn.c        |   58 ++++----
>  net/bluetooth/hci_core.c        |  151 +++++++++++----------
>  net/bluetooth/hci_event.c       |  282 ++++++++++++++++++++-------------------
>  net/bluetooth/hci_sock.c        |   20 ++--
>  net/bluetooth/hci_sysfs.c       |    8 +-
>  net/bluetooth/hidp/core.c       |   44 ++++---
>  net/bluetooth/hidp/sock.c       |    6 +-
>  net/bluetooth/l2cap_core.c      |  189 ++++++++++++++-------------
>  net/bluetooth/l2cap_sock.c      |   34 +++---
>  net/bluetooth/mgmt.c            |   89 ++++++------
>  net/bluetooth/rfcomm/core.c     |  164 ++++++++++++-----------
>  net/bluetooth/rfcomm/sock.c     |   49 ++++----
>  net/bluetooth/rfcomm/tty.c      |   88 ++++++------
>  net/bluetooth/sco.c             |   69 +++++-----
>  net/bluetooth/smp.c             |   33 +++---
>  37 files changed, 915 insertions(+), 874 deletions(-)

this one has to wait. You are disturbing multiple developers that are
working on core features.

Regards

Marcel
