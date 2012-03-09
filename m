From: Johan Hovold <jhovold@gmail.com>
Subject: [PATCH 0/3] bluetooth: bug fixes for 3.3
Date: Fri,  9 Mar 2012 16:43:23 +0100
Message-ID: <1331307806-21761-1-git-send-email-jhovold@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	David Herrmann <dh.herrmann@googlemail.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	Johan Hovold <jhovold@gmail.com>
To: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, 

This is a revised series which also contains a minimal fix to the memory leak
discovered by David Hermann upon which the first NULL-pointer-dereference fix
also depends.

These patches need to get to Linus ASAP as the problems are present in 3.3-rc6
as well as earlier kernels and thus should be backported to the stable trees as
well.

Thanks,
Johan


Johan Hovold (3):
  bluetooth: hci_ldisc: fix memory leak on tty_close
  bluetooth: hci_ldisc: fix NULL-pointer dereference on tty_close
  bluetooth: hci_core: fix NULL-pointer dereference at unregister

 drivers/bluetooth/hci_ldisc.c |    4 ++--
 include/net/bluetooth/hci.h   |    2 ++
 net/bluetooth/hci_core.c      |    7 +++++++
 3 files changed, 11 insertions(+), 2 deletions(-)

-- 
1.7.8.4
