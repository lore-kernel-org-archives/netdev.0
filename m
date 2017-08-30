From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/2] staging: r8822be: Remove some left-over debug code
Date: Wed, 30 Aug 2017 14:43:11 -0500
Message-ID: <20170830194313.9659-1-Larry.Finger@lwfinger.net>
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

Some useless debugging code from the initial writing of the driver was not
removed before it was submitted. That oversight is now fixed and the
remaining code in routine deinit_priv() is simplified.

Larry

Larry Finger (2):
  staging: r8822be: Remove some dead code
  staging: r8822be: Simplify deinit_priv()

 drivers/staging/rtlwifi/halmac/rtl_halmac.c | 28 +---------------------------
 1 file changed, 1 insertion(+), 27 deletions(-)

-- 
2.12.3
