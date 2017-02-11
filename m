From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/7] Fix Sparse endian warnings in r8712u
Date: Fri, 10 Feb 2017 21:30:23 -0600
Message-ID: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Now that endian checking is an automatic part of Sparse, it is advisable
to fix these warnings under controlled conditions, which include testing
on big-endian hardware. This set of patches fix all the issues.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (7):
  staging: r8712u: Fix some Sparse endian messages
  staging: r8712u: Fix endian settings for structs describing network
    packets
  staging: r8712u: Fix macros used to read/write the TX/RX descriptors
  staging: r8712u: Fix Sparse warning in rtl871x_xmit.c
  staging: r8712u: Fix Sparse endian warning in rtl871x_recv.c
  staging: r8712u: Fix Sparse warnings in rtl871x_ioctl_linux.c
  staging: r8712u: Fix Sparse warnings in rtl871x_mlme.c

 drivers/staging/rtl8712/ieee80211.h           |  84 ++++++++++----------
 drivers/staging/rtl8712/rtl8712_xmit.c        |   6 +-
 drivers/staging/rtl8712/rtl871x_ioctl_linux.c |   4 +-
 drivers/staging/rtl8712/rtl871x_mlme.c        |   9 +--
 drivers/staging/rtl8712/rtl871x_recv.c        |   5 +-
 drivers/staging/rtl8712/rtl871x_xmit.c        |   7 +-
 drivers/staging/rtl8712/wifi.h                | 109 ++++++++++++--------------
 7 files changed, 110 insertions(+), 114 deletions(-)

-- 
2.10.2
