From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH v2 net-next 0/2] e1000e: fix PTP on e1000_pch_variants
Date: Sat, 23 Jul 2016 12:44:32 -0400
Message-ID: <1469292274-59237-1-git-send-email-jarod@redhat.com>
References: <1468959902-25071-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468959902-25071-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This little series factors out the systim sanitization code first, then
adds e1000_pch_lpt as a new case in the switch that calls the sanitize
function, fixing PTP clock issues I've had reported against an Intel
I-218V NIC in an Intel NUC5ik5RYH system.

Jarod Wilson (2):
  e1000e: factor out systim sanitization
  e1000e: fix PTP on e1000_pch_lpt variants

Note: this series replaces the previously submitted singleton patch that
was, er, broken, titled the same.

Reported-by: Rupesh Patel <rupatel@redhat.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: intel-wired-lan@lists.osuosl.org
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>

 drivers/net/ethernet/intel/e1000e/netdev.c | 72 +++++++++++++++++++-----------
 1 file changed, 45 insertions(+), 27 deletions(-)

-- 
1.8.3.1
