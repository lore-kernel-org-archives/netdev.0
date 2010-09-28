From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: pull-request: bluetooth-2.6 2010-09-27
Date: Mon, 27 Sep 2010 23:30:35 -0300
Message-ID: <20100928023035.GA3033@vigoh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

These are the Bluetooth fixes for 2.6.36, you are used to see Marcel doing this
job, but he has been busy lately so I'm taking the job of the pull request this
time. Since we are a bit late on the pull request I'm skipping the
wireless-2.6 step, tell me if you (including John here) disagree.

In this patch set we have two fixes for regressions in L2CAP due to ERTM code
we added in L2CAP for 2.6.36, a bugfix in the L2CAP Streaming Mode that was
making the kernel crash. And a fix for a deadlock issue between the sk_sndbuf
and the backlog queue in ERTM. The rest are also needed bug fixes.

Please tell me any problem you have pulling this.

PS: Considering that these patches do not go immediately to net-next how do I
run the Bluetooth pull request to net-next? Currently my -next tree is rebased
on net-next but before the bluetooth-next patches I put the bluetooth patches
I have in my bluetooth-2.6 tree, i.e., when making the pull request I have to be
sure that the -next patches will be on top of the patches I'm submitting now
for 2.6.36. Any help on that is welcome. :)

Regards,


---

The following changes since commit b30a3f6257ed2105259b404d419b4964e363928c:

  Linux 2.6.36-rc5 (2010-09-20 16:56:53 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/padovan/bluetooth-2.6.git master

Andrei Emeltchenko (1):
      Bluetooth: fix MTU L2CAP configuration parameter

Gustavo F. Padovan (4):
      Bluetooth: Simplify L2CAP Streaming mode sending
      Bluetooth: Fix inconsistent lock state with RFCOMM
      Revert "Bluetooth: Don't accept ConfigReq if we aren't in the BT_CONFIG state"
      Bluetooth: Fix deadlock in the ERTM logic

Mat Martineau (1):
      Bluetooth: Only enable L2CAP FCS for ERTM or streaming

 include/net/bluetooth/bluetooth.h |   11 +++++++
 net/bluetooth/l2cap.c             |   57 +++++++++++++++---------------------
 net/bluetooth/rfcomm/sock.c       |    4 ++
 3 files changed, 39 insertions(+), 33 deletions(-)

-- 
Gustavo F. Padovan
ProFUSION embedded systems - http://profusion.mobi
