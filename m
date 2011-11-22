From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v2 0/4] e1000e: ethtool setfeatures fixes + loopback
Date: Tue, 22 Nov 2011 11:23:34 -0800
Message-ID: <cover.1321989502.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Decotigny <david.decotigny@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes a bug in ethtool setfeatures and adds loopback
support through ethtool setfeatures.

I believe these patches could easily be adapted to e1000, but I don't
have the hardware to test.

Changes since v1:
  - simplification in patch 1/4 (from Micha=C5=82 Miros=C5=82aw)

############################################
# Patch Set Summary:

David Decotigny (2):
  net-e1000e: fix ethtool set_features taking new features into account
    too late
  net-e1000e: ethtool loopback support

Maciej =C5=BBenczykowski (2):
  net-e1000e: reworked carrier detection logic
  net-e1000e: Report carrier in loopback mode

 drivers/net/ethernet/intel/e1000e/e1000.h   |    2 +
 drivers/net/ethernet/intel/e1000e/ethtool.c |    6 +-
 drivers/net/ethernet/intel/e1000e/netdev.c  |   32 +++++++++++-
 drivers/net/ethernet/intel/e1000e/phy.c     |   69 +++++++++++++++++--=
--------
 4 files changed, 78 insertions(+), 31 deletions(-)

--=20
1.7.3.1
