From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 0/2] Revert and reimplement Add SGMII support to UCC GETH
Date: Wed, 17 Jun 2009 15:09:44 -0600
Message-ID: <20090617210356.18435.96410.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sachin P Sant <sachinp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	Linux-Next <linux-next@vger.kernel.org>, Nathan Lynch <ntl@pobox.com>,
	Haiying Wang <Haiying.Wang@freescale.com>, Li Yang <leoli@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>, subrata@linux.vnet.ibm.com,
	netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Here is a fix for the build failure discovered during the 2.6.31 merge
window on ucc_geth.c.  I decided to revert and reapply a fixed version
of the patch to make the new version easier to review and bisect if I
got the fixup wrong.  I've compile tested both patches, but I do not have
hardware to run test.

Haiying, please confirm that I haven't horribly trashed your hard work
with my changes.

For anyone interested, I've also pushed these patches out to the -next-net
branch of my git tree:

The following changes since commit 65795efbd380a832ae508b04dba8f8e53f0b84d9:
  Linus Torvalds (1):
        Merge branch 'next-i2c' of git://aeryn.fluff.org.uk/bjdooks/linux

are available in the git repository at:

  git://git.secretlab.ca/git/linux-2.6 next-net

Grant Likely (1):
      Revert "net/ucc_geth: Add SGMII support for UEC GETH driver"

Haiying Wang (1):
      net/ucc_geth: Add SGMII support for UCC GETH driver

 drivers/net/ucc_geth.c |  113 +++++++++++++++++++----------------------------
 drivers/net/ucc_geth.h |    2 +-
 2 files changed, 47 insertions(+), 68 deletions(-)


--
Grant Likely, B.Sc. P.Eng.
Secret Lab Technologies Ltd.
