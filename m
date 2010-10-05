From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: pull-request: bluetooth-2.6 2010-10-05
Date: Tue, 5 Oct 2010 14:13:49 -0300
Message-ID: <20101005171349.GA16520@vigoh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

In this patch set we have two fixes for regressions in L2CAP due to ERTM code
we added in L2CAP for 2.6.36, a bugfix in the L2CAP Streaming Mode that was
making the kernel crash. And a fix for a deadlock issue between the sk_sndbuf
and the backlog queue in ERTM. The rest are also needed bug fixes.

For -next pull request things go back to normal and patches go through John.

Thanks!


The following changes since commit 899611ee7d373e5eeda08e9a8632684e1ebbbf00:

  Linux 2.6.36-rc6 (2010-09-28 18:01:22 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/padovan/bluetooth-2.6.git master

Andrei Emeltchenko (1):
      Bluetooth: fix MTU L2CAP configuration parameter

Gustavo F. Padovan (5):
      Bluetooth: Simplify L2CAP Streaming mode sending
      Bluetooth: Fix inconsistent lock state with RFCOMM
      Revert "Bluetooth: Don't accept ConfigReq if we aren't in the BT_CONFIG state"
      Bluetooth: Fix deadlock in the ERTM logic
      Bluetooth: Disallow to change L2CAP_OPTIONS values when connected

Mat Martineau (1):
      Bluetooth: Only enable L2CAP FCS for ERTM or streaming

 include/net/bluetooth/bluetooth.h |   18 +++++++++++
 net/bluetooth/l2cap.c             |   62 +++++++++++++++++-------------------
 net/bluetooth/rfcomm/sock.c       |    4 ++
 3 files changed, 51 insertions(+), 33 deletions(-)

-- 
Gustavo F. Padovan
ProFUSION embedded systems - http://profusion.mobi
