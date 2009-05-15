From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.30] WiMAX pull request
Date: Fri, 15 May 2009 12:07:32 -0700
Message-ID: <cover.1242405228.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org,
	wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

This patch fixes a device crash due to a bad optimization. It won't
crash the system, but just render the WiMAX device unusable on bad
radio link conditions. 

The following changes since commit e1cc1c578055d20d36e084e324001fb5e0355a71:
  David S. Miller (1):
        Merge branch 'net-fixes' of git://git.kernel.org/.../chris/linux-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git linux-2.6.30.y

Patches follow for reviewing convenience.

Inaky Perez-Gonzalez (1):
      wimax/i2400m: fix device crash: fix optimization in _roq_queue_update_ws

 drivers/net/wimax/i2400m/rx.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)
