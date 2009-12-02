From: Patrick Mullaney <pmullaney@novell.com>
Subject: [PATCH 0/2] registration fixes for vbus venet macvlan driver
Date: Wed, 02 Dec 2009 16:10:19 -0500
Message-ID: <20091202204722.5116.33183.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applies to alacrityvm.git/master:4ac12ced9)

These patches fix some netdev registration problems discovered with
the venet macvlan driver. The newline patch is trivial. The other
patch addresses several problems with registration. Worth noting
are the problems registering a netdevice that has previously been
unregistered. This doesn't seem work and I was wondering if this
is expected behavior in net/core(see patch 2/2 for a description).

---

Patrick Mullaney (2):
      venet: Fixes for shutdown and re-registration of venet devices.
      venet-macvlan: correctly remove newline from lower device name


 kernel/vbus/devices/venet/device.c      |   11 ++++--
 kernel/vbus/devices/venet/macvlan.c     |   61 +++++++++++++++++++++++++------
 kernel/vbus/devices/venet/venetdevice.h |    7 +++-
 3 files changed, 63 insertions(+), 16 deletions(-)

-- 
