From: <panduranga_mallireddy@ti.com>
Subject: [PATCH 0/1] OMAP: WLAN : To fix a WLAN related bug in
	Kernel 3.0
Date: Tue, 16 Aug 2011 10:03:56 -0500
Message-ID: <1313507037-2467-1-git-send-email-panduranga_mallireddy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ohad@wizery.com, Panduranga Mallireddy <panduranga_mallireddy@ti.com>,
        pradeepgurumath@ti.com, coelho@ti.com, netdev@vger.kernel.org,
        naveen_jain@ti.com, x-boudet@ti.com, vishalm@ti.com,
        manjunatha_halli@ti.com, benzyg@ti.com, linux-omap@vger.kernel.org
To: <stable@kernel.org>
Return-path: <stable-bounces@linux.kernel.org>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

From: Panduranga Mallireddy <panduranga_mallireddy@ti.com>

Error reported for wl12xx driver with Kernel 3.0 is
[    0.181457] error setting wl12xx data

FIX:
For regulator omap4_clk32k used by wlan, set .constraints.always_on to 1 

Panduranga Mallireddy (1):
  OMAP: wlan: Set the WLAN Regulator to be always on

 arch/arm/mach-omap2/twl-common.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable
