From: Jason Wang <jasowang@redhat.com>
Subject: [RFC v3 PATCH 4/4] virtio-net: compat guest announce support.
Date: Thu, 27 Oct 2011 16:49:06 +0800
Message-ID: <20111027084906.15020.6622.stgit@dhcp-8-146.nay.redhat.com>
References: <20111027084700.15020.24087.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: aliguori@us.ibm.com, mst@redhat.com, jan.kiszka@siemens.com,
	rusty@rustcorp.com.au, qemu-devel@nongnu.org, blauwirbel@gmail.com,
	stefanha@gmail.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111027084700.15020.24087.stgit@dhcp-8-146.nay.redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Disable guest announce for compat machine types.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 hw/pc_piix.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/hw/pc_piix.c b/hw/pc_piix.c
index 8c7f2b7..6ca50a6 100644
--- a/hw/pc_piix.c
+++ b/hw/pc_piix.c
@@ -340,6 +340,10 @@ static QEMUMachine pc_machine_v0_13 = {
             .driver   = "virtio-net-pci",
             .property = "event_idx",
             .value    = "off",
+        },{
+            .driver   = "virtio-net-pci",
+            .property = "guest_announce",
+            .value    = "off",
         },
         { /* end of list */ }
     },
@@ -383,6 +387,10 @@ static QEMUMachine pc_machine_v0_12 = {
             .driver   = "virtio-net-pci",
             .property = "event_idx",
             .value    = "off",
+        },{
+            .driver   = "virtio-net-pci",
+            .property = "guest_announce",
+            .value    = "off",
         },
         { /* end of list */ }
     }
@@ -434,6 +442,10 @@ static QEMUMachine pc_machine_v0_11 = {
             .driver   = "virtio-net-pci",
             .property = "event_idx",
             .value    = "off",
+        },{
+            .driver   = "virtio-net-pci",
+            .property = "guest_announce",
+            .value    = "off",
         },
         { /* end of list */ }
     }
@@ -497,6 +509,10 @@ static QEMUMachine pc_machine_v0_10 = {
             .driver   = "virtio-net-pci",
             .property = "event_idx",
             .value    = "off",
+        },{
+            .driver   = "virtio-net-pci",
+            .property = "guest_announce",
+            .value    = "off",
         },
         { /* end of list */ }
     },

