From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [pull 2.6.30 0/2] WiMAX fixes for 2.6.30
Date: Wed,  6 May 2009 14:47:21 -0700
Message-ID: <cover.1241646234.git.inaky@linux.intel.com>
Cc: netdev@vger.kernel.org
To: wimax@linuxwimax.org
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

These fix a couple of oopsen found in the WiMAX stack. They are
available as a pull and patches are included for revieweing
convenience.

Thank you,

--

The following changes since commit 356d6c2d55b71303a17910ea2cce3eba8e44bd29:
  David S. Miller (1):
        Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git linux-2.6.30.y

Inaky Perez-Gonzalez (2):
      wimax: fix oops if netlink fails to add attribute
      wimax: oops: wimax_dev_add() is the only one that can initialize the state

 net/wimax/op-msg.c |   11 ++++++-----
 net/wimax/stack.c  |   17 +++++++++++++++--
 2 files changed, 21 insertions(+), 7 deletions(-)
