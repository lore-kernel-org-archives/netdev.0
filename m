From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 0/2] Revert and reimplement Add SGMII support to UCC GETH
Date: Wed, 17 Jun 2009 17:15:58 -0600
Message-ID: <20090617231306.7051.56146.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>,
	Li Yang <leoli@freescale.com>, Nathan Lynch <ntl@pobox.com>,
	Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linux-Next <linux-next@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Balbir Singh <balbir@linux.vnet.ibm.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	Tony Breeds <tony@bakeyournoodle.com>, michael@ellerman.id.au,
	Haiying Wang <Haiying.Wang@freescale.com>, davem@davemloft.net
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	subrata@linux.vnet.ibm.com, netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(REPOST; I messed up an email address first time around and apparently my
posting got rejected.  If you've already received this message, then
I apologize for the noise)

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
