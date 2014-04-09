From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/3] Fix some bugs in staging drivers
Date: Wed,  9 Apr 2014 11:12:57 -0500
Message-ID: <1397059980-11942-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

While analyzing parts of the recently merged r8723au driver, Jes Sorensen
found two bugs that are found in other Reaktek drivers in staging. This
set of patches fixes them.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (3):
  staging: r8188eu: Calling rtw_get_stainfo() with a NULL sta_addr will
    return NULL
  staging: r8188eu: Fix case where ethtype was never obtained and always
    be checked against 0
  staging: r8712u: Fix case where ethtype was never obtained and always
    be checked against 0

 drivers/staging/rtl8188eu/core/rtw_recv.c | 24 ++++++++++--------------
 drivers/staging/rtl8712/rtl871x_recv.c    | 15 +++++++--------
 2 files changed, 17 insertions(+), 22 deletions(-)

-- 
1.8.1.4
