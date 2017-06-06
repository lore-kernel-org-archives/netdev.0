From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates 2017-06-06
Date: Tue,  6 Jun 2017 03:00:53 -0700
Message-ID: <20170606100055.63648-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:21678 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751333AbdFFKBA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 06:01:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to i40e and i40evf only.

Mauro S. M. Rodrigues fixes a flood in the kernel log which was introduced
in a previous commit because of a mistaken substitution of __I40E_VSI_DOWN
instead of __I40E_DOWN when testing the state of the PF.

Björn Töpel fixes an issue introduced in a previous commit where the
offset was incorrect and could lead to data corruption for architectures
using PAGE_SIZE larger than 8191.  Fixed the issue by updating the
page_offset correctly using the proper setting for truesize.

The following are changes since commit 269f9883fe254d109afdfc657875c456d6fabb08:
  net/mlx4: Check if Granular QoS per VF has been enabled before updating QP qos_vport
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue 40GbE

Björn Töpel (1):
  i40e/i40evf: proper update of the page_offset field

Mauro S. M. Rodrigues (1):
  i40e: Fix state flags for bit set and clean operations of PF

 drivers/net/ethernet/intel/i40e/i40e_main.c   | 36 +++++++++++++--------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |  3 ++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |  3 ++-
 3 files changed, 22 insertions(+), 20 deletions(-)

-- 
2.12.2
