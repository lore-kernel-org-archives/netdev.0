From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.14 (take #2)] fec_8xx: make CONFIG_FEC_8XX depend on
	CONFIG_8xx
Date: Wed, 9 Nov 2005 16:52:39 -0500
Message-ID: <20051109215237.GC24099@tuxdriver.com>
References: <20051106025701.GA9698@tuxdriver.com>
	<436F07F5.1030206@intracom.gr>
	<20051107182031.GC13797@tuxdriver.com>
	<20051107182459.GD13797@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Pantelis Antoniou <panto@intracom.gr>, linuxppc-embedded@ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20051107182459.GD13797@tuxdriver.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 07, 2005 at 01:24:59PM -0500, John W. Linville wrote:
> Change CONFIG_FEC_8XX to depend on CONFIG_8xx instead of CONFIG_FEC.
> CONFIG_FEC depends on ColdFire CPUs, which does not apply for the
> PPC 8xx processors.

FWIW, I have this patch available on the linville-fec_8xx branch of
netdev-jwl as described below.

Thanks,

John

---

The following changes since commit 330d57fb98a916fa8e1363846540dd420e99499a:
  Al Viro:
        Fix sysctl unregistration oops (CVE-2005-2709)

are found in the git repository at:

  git://git.tuxdriver.com/git/netdev-jwl.git linville-fec_8xx

John W. Linville:
      fec_8xx: make CONFIG_FEC_8XX depend on CONFIG_8xx

 drivers/net/fec_8xx/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec_8xx/Kconfig b/drivers/net/fec_8xx/Kconfig
index 94e7a9a..a84c232 100644
--- a/drivers/net/fec_8xx/Kconfig
+++ b/drivers/net/fec_8xx/Kconfig
@@ -1,6 +1,6 @@
 config FEC_8XX
 	tristate "Motorola 8xx FEC driver"
-	depends on NET_ETHERNET && FEC
+	depends on NET_ETHERNET && 8xx
 	select MII
 
 config FEC_8XX_GENERIC_PHY
-- 
John W. Linville
linville@tuxdriver.com
