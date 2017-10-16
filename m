From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH v2 02/15] usb: gadget: make config_item_type
	structures const
Date: Mon, 16 Oct 2017 17:18:41 +0200
Message-ID: <1508167134-6243-3-git-send-email-bhumirks@gmail.com>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
	alexander.shishkin@linux.intel.com, jic23@kernel.org, knaack.h@gmx.de,
	lars@metafoo.de, pmeerw@pmeerw.net, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, hch@lst.de,
	sagi@grimberg.me, kishon@ti.com, bhelgaas@google.com,
	nab@linux-iscsi.org, balbi@kernel.org, gregkh@linuxfoundation.org,
	laurent.pinchart@ideasonboard.com, jlbec@evilplan.org,
	ccaulfie@redhat.com, teigland@redhat.com, mfasheh@versity.com,
	linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-iio@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, linux-usb@vger.kernel.org,
	cluster-devel@redhat.com, ocfs2-devel@oss.oracle.com,
	linux-fsdevel@vger.kernel.org
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Make these structures const as they are only passed to the const
argument of the functions config_{group/item}_init_type_name.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
* Changes in v2- Combine all the followup patches and the constification
patches into a series.

 drivers/usb/gadget/function/f_acm.c          |  2 +-
 drivers/usb/gadget/function/f_ecm.c          |  2 +-
 drivers/usb/gadget/function/f_eem.c          |  2 +-
 drivers/usb/gadget/function/f_fs.c           |  2 +-
 drivers/usb/gadget/function/f_hid.c          |  2 +-
 drivers/usb/gadget/function/f_loopback.c     |  2 +-
 drivers/usb/gadget/function/f_mass_storage.c |  4 +--
 drivers/usb/gadget/function/f_midi.c         |  2 +-
 drivers/usb/gadget/function/f_ncm.c          |  2 +-
 drivers/usb/gadget/function/f_obex.c         |  2 +-
 drivers/usb/gadget/function/f_phonet.c       |  2 +-
 drivers/usb/gadget/function/f_printer.c      |  2 +-
 drivers/usb/gadget/function/f_rndis.c        |  2 +-
 drivers/usb/gadget/function/f_serial.c       |  2 +-
 drivers/usb/gadget/function/f_sourcesink.c   |  2 +-
 drivers/usb/gadget/function/f_subset.c       |  2 +-
 drivers/usb/gadget/function/f_tcm.c          |  2 +-
 drivers/usb/gadget/function/f_uac1.c         |  2 +-
 drivers/usb/gadget/function/f_uac1_legacy.c  |  2 +-
 drivers/usb/gadget/function/f_uac2.c         |  2 +-
 drivers/usb/gadget/function/uvc_configfs.c   | 50 ++++++++++++++--------------
 21 files changed, 46 insertions(+), 46 deletions(-)

diff --git a/drivers/usb/gadget/function/f_acm.c b/drivers/usb/gadget/function/f_acm.c
index 5e3828d..8680af4 100644
--- a/drivers/usb/gadget/function/f_acm.c
+++ b/drivers/usb/gadget/function/f_acm.c
@@ -786,7 +786,7 @@ static ssize_t f_acm_port_num_show(struct config_item *item, char *page)
 	NULL,
 };
 
-static struct config_item_type acm_func_type = {
+static const struct config_item_type acm_func_type = {
 	.ct_item_ops    = &acm_item_ops,
 	.ct_attrs	= acm_attrs,
 	.ct_owner       = THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_ecm.c b/drivers/usb/gadget/function/f_ecm.c
index 4c488d1..9657e19 100644
--- a/drivers/usb/gadget/function/f_ecm.c
+++ b/drivers/usb/gadget/function/f_ecm.c
@@ -845,7 +845,7 @@ static inline struct f_ecm_opts *to_f_ecm_opts(struct config_item *item)
 	NULL,
 };
 
-static struct config_item_type ecm_func_type = {
+static const struct config_item_type ecm_func_type = {
 	.ct_item_ops	= &ecm_item_ops,
 	.ct_attrs	= ecm_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_eem.c b/drivers/usb/gadget/function/f_eem.c
index 007ec6e..5e5d164 100644
--- a/drivers/usb/gadget/function/f_eem.c
+++ b/drivers/usb/gadget/function/f_eem.c
@@ -556,7 +556,7 @@ static inline struct f_eem_opts *to_f_eem_opts(struct config_item *item)
 	NULL,
 };
 
-static struct config_item_type eem_func_type = {
+static const struct config_item_type eem_func_type = {
 	.ct_item_ops	= &eem_item_ops,
 	.ct_attrs	= eem_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_fs.c b/drivers/usb/gadget/function/f_fs.c
index 8b34258..5362fc4 100644
--- a/drivers/usb/gadget/function/f_fs.c
+++ b/drivers/usb/gadget/function/f_fs.c
@@ -3385,7 +3385,7 @@ static void ffs_attr_release(struct config_item *item)
 	.release	= ffs_attr_release,
 };
 
-static struct config_item_type ffs_func_type = {
+static const struct config_item_type ffs_func_type = {
 	.ct_item_ops	= &ffs_item_ops,
 	.ct_owner	= THIS_MODULE,
 };
diff --git a/drivers/usb/gadget/function/f_hid.c b/drivers/usb/gadget/function/f_hid.c
index d8e359e..6993cb8 100644
--- a/drivers/usb/gadget/function/f_hid.c
+++ b/drivers/usb/gadget/function/f_hid.c
@@ -992,7 +992,7 @@ static ssize_t f_hid_opts_dev_show(struct config_item *item, char *page)
 	NULL,
 };
 
-static struct config_item_type hid_func_type = {
+static const struct config_item_type hid_func_type = {
 	.ct_item_ops	= &hidg_item_ops,
 	.ct_attrs	= hid_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_loopback.c b/drivers/usb/gadget/function/f_loopback.c
index e700938..9311f8c 100644
--- a/drivers/usb/gadget/function/f_loopback.c
+++ b/drivers/usb/gadget/function/f_loopback.c
@@ -556,7 +556,7 @@ static ssize_t f_lb_opts_bulk_buflen_store(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type lb_func_type = {
+static const struct config_item_type lb_func_type = {
 	.ct_item_ops    = &lb_item_ops,
 	.ct_attrs	= lb_attrs,
 	.ct_owner       = THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_mass_storage.c b/drivers/usb/gadget/function/f_mass_storage.c
index 5153e29..a538be3 100644
--- a/drivers/usb/gadget/function/f_mass_storage.c
+++ b/drivers/usb/gadget/function/f_mass_storage.c
@@ -3140,7 +3140,7 @@ static ssize_t fsg_lun_opts_inquiry_string_store(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type fsg_lun_type = {
+static const struct config_item_type fsg_lun_type = {
 	.ct_item_ops	= &fsg_lun_item_ops,
 	.ct_attrs	= fsg_lun_attrs,
 	.ct_owner	= THIS_MODULE,
@@ -3331,7 +3331,7 @@ static ssize_t fsg_opts_num_buffers_store(struct config_item *item,
 	.drop_item	= fsg_lun_drop,
 };
 
-static struct config_item_type fsg_func_type = {
+static const struct config_item_type fsg_func_type = {
 	.ct_item_ops	= &fsg_item_ops,
 	.ct_group_ops	= &fsg_group_ops,
 	.ct_attrs	= fsg_attrs,
diff --git a/drivers/usb/gadget/function/f_midi.c b/drivers/usb/gadget/function/f_midi.c
index 5d3d794..53fa073 100644
--- a/drivers/usb/gadget/function/f_midi.c
+++ b/drivers/usb/gadget/function/f_midi.c
@@ -1189,7 +1189,7 @@ static ssize_t f_midi_opts_id_store(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type midi_func_type = {
+static const struct config_item_type midi_func_type = {
 	.ct_item_ops	= &midi_item_ops,
 	.ct_attrs	= midi_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_ncm.c b/drivers/usb/gadget/function/f_ncm.c
index 45b334c..3599aa4 100644
--- a/drivers/usb/gadget/function/f_ncm.c
+++ b/drivers/usb/gadget/function/f_ncm.c
@@ -1568,7 +1568,7 @@ static inline struct f_ncm_opts *to_f_ncm_opts(struct config_item *item)
 	NULL,
 };
 
-static struct config_item_type ncm_func_type = {
+static const struct config_item_type ncm_func_type = {
 	.ct_item_ops	= &ncm_item_ops,
 	.ct_attrs	= ncm_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_obex.c b/drivers/usb/gadget/function/f_obex.c
index d43e86c..9fc7988 100644
--- a/drivers/usb/gadget/function/f_obex.c
+++ b/drivers/usb/gadget/function/f_obex.c
@@ -411,7 +411,7 @@ static ssize_t f_obex_port_num_show(struct config_item *item, char *page)
 	NULL,
 };
 
-static struct config_item_type obex_func_type = {
+static const struct config_item_type obex_func_type = {
 	.ct_item_ops	= &obex_item_ops,
 	.ct_attrs	= acm_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_phonet.c b/drivers/usb/gadget/function/f_phonet.c
index 9c4c58e..5fe1f2a 100644
--- a/drivers/usb/gadget/function/f_phonet.c
+++ b/drivers/usb/gadget/function/f_phonet.c
@@ -599,7 +599,7 @@ static ssize_t f_phonet_ifname_show(struct config_item *item, char *page)
 	NULL,
 };
 
-static struct config_item_type phonet_func_type = {
+static const struct config_item_type phonet_func_type = {
 	.ct_item_ops	= &phonet_item_ops,
 	.ct_attrs	= phonet_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_printer.c b/drivers/usb/gadget/function/f_printer.c
index ea0da35a..8072836 100644
--- a/drivers/usb/gadget/function/f_printer.c
+++ b/drivers/usb/gadget/function/f_printer.c
@@ -1261,7 +1261,7 @@ static ssize_t f_printer_opts_q_len_store(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type printer_func_type = {
+static const struct config_item_type printer_func_type = {
 	.ct_item_ops	= &printer_item_ops,
 	.ct_attrs	= printer_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_rndis.c b/drivers/usb/gadget/function/f_rndis.c
index c7c5b3c..b981545 100644
--- a/drivers/usb/gadget/function/f_rndis.c
+++ b/drivers/usb/gadget/function/f_rndis.c
@@ -890,7 +890,7 @@ static inline struct f_rndis_opts *to_f_rndis_opts(struct config_item *item)
 	NULL,
 };
 
-static struct config_item_type rndis_func_type = {
+static const struct config_item_type rndis_func_type = {
 	.ct_item_ops	= &rndis_item_ops,
 	.ct_attrs	= rndis_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_serial.c b/drivers/usb/gadget/function/f_serial.c
index cb00ada..4ee860b 100644
--- a/drivers/usb/gadget/function/f_serial.c
+++ b/drivers/usb/gadget/function/f_serial.c
@@ -281,7 +281,7 @@ static ssize_t f_serial_port_num_show(struct config_item *item, char *page)
 	NULL,
 };
 
-static struct config_item_type serial_func_type = {
+static const struct config_item_type serial_func_type = {
 	.ct_item_ops	= &serial_item_ops,
 	.ct_attrs	= acm_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_sourcesink.c b/drivers/usb/gadget/function/f_sourcesink.c
index 8784fa1..ed22e18 100644
--- a/drivers/usb/gadget/function/f_sourcesink.c
+++ b/drivers/usb/gadget/function/f_sourcesink.c
@@ -1230,7 +1230,7 @@ static ssize_t f_ss_opts_iso_qlen_store(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type ss_func_type = {
+static const struct config_item_type ss_func_type = {
 	.ct_item_ops    = &ss_item_ops,
 	.ct_attrs	= ss_attrs,
 	.ct_owner       = THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_subset.c b/drivers/usb/gadget/function/f_subset.c
index 434b983..e810d15 100644
--- a/drivers/usb/gadget/function/f_subset.c
+++ b/drivers/usb/gadget/function/f_subset.c
@@ -412,7 +412,7 @@ static inline struct f_gether_opts *to_f_gether_opts(struct config_item *item)
 	NULL,
 };
 
-static struct config_item_type gether_func_type = {
+static const struct config_item_type gether_func_type = {
 	.ct_item_ops	= &gether_item_ops,
 	.ct_attrs	= gether_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_tcm.c b/drivers/usb/gadget/function/f_tcm.c
index a82e2bd..e3cec75 100644
--- a/drivers/usb/gadget/function/f_tcm.c
+++ b/drivers/usb/gadget/function/f_tcm.c
@@ -2166,7 +2166,7 @@ static void tcm_attr_release(struct config_item *item)
 	.release		= tcm_attr_release,
 };
 
-static struct config_item_type tcm_func_type = {
+static const struct config_item_type tcm_func_type = {
 	.ct_item_ops	= &tcm_item_ops,
 	.ct_owner	= THIS_MODULE,
 };
diff --git a/drivers/usb/gadget/function/f_uac1.c b/drivers/usb/gadget/function/f_uac1.c
index 29efbed..4d5487a 100644
--- a/drivers/usb/gadget/function/f_uac1.c
+++ b/drivers/usb/gadget/function/f_uac1.c
@@ -709,7 +709,7 @@ static void f_uac1_attr_release(struct config_item *item)
 	NULL,
 };
 
-static struct config_item_type f_uac1_func_type = {
+static const struct config_item_type f_uac1_func_type = {
 	.ct_item_ops	= &f_uac1_item_ops,
 	.ct_attrs	= f_uac1_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_uac1_legacy.c b/drivers/usb/gadget/function/f_uac1_legacy.c
index 5d229e7..178fd12 100644
--- a/drivers/usb/gadget/function/f_uac1_legacy.c
+++ b/drivers/usb/gadget/function/f_uac1_legacy.c
@@ -921,7 +921,7 @@ static void f_uac1_attr_release(struct config_item *item)
 	NULL,
 };
 
-static struct config_item_type f_uac1_func_type = {
+static const struct config_item_type f_uac1_func_type = {
 	.ct_item_ops	= &f_uac1_item_ops,
 	.ct_attrs	= f_uac1_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/f_uac2.c b/drivers/usb/gadget/function/f_uac2.c
index f05c3f3..7bb9737 100644
--- a/drivers/usb/gadget/function/f_uac2.c
+++ b/drivers/usb/gadget/function/f_uac2.c
@@ -921,7 +921,7 @@ static void f_uac2_attr_release(struct config_item *item)
 	NULL,
 };
 
-static struct config_item_type f_uac2_func_type = {
+static const struct config_item_type f_uac2_func_type = {
 	.ct_item_ops	= &f_uac2_item_ops,
 	.ct_attrs	= f_uac2_attrs,
 	.ct_owner	= THIS_MODULE,
diff --git a/drivers/usb/gadget/function/uvc_configfs.c b/drivers/usb/gadget/function/uvc_configfs.c
index 844cb73..f76619f 100644
--- a/drivers/usb/gadget/function/uvc_configfs.c
+++ b/drivers/usb/gadget/function/uvc_configfs.c
@@ -127,7 +127,7 @@ static struct uvcg_control_header *to_uvcg_control_header(struct config_item *it
 	NULL,
 };
 
-static struct config_item_type uvcg_control_header_type = {
+static const struct config_item_type uvcg_control_header_type = {
 	.ct_attrs	= uvcg_control_header_attrs,
 	.ct_owner	= THIS_MODULE,
 };
@@ -170,7 +170,7 @@ static void uvcg_control_header_drop(struct config_group *group,
 	.drop_item		= uvcg_control_header_drop,
 };
 
-static struct config_item_type uvcg_control_header_grp_type = {
+static const struct config_item_type uvcg_control_header_grp_type = {
 	.ct_group_ops	= &uvcg_control_header_grp_ops,
 	.ct_owner	= THIS_MODULE,
 };
@@ -265,7 +265,7 @@ static ssize_t uvcg_default_processing_bm_controls_show(
 	NULL,
 };
 
-static struct config_item_type uvcg_default_processing_type = {
+static const struct config_item_type uvcg_default_processing_type = {
 	.ct_attrs	= uvcg_default_processing_attrs,
 	.ct_owner	= THIS_MODULE,
 };
@@ -277,7 +277,7 @@ static ssize_t uvcg_default_processing_bm_controls_show(
 	struct config_group	group;
 } uvcg_processing_grp;
 
-static struct config_item_type uvcg_processing_grp_type = {
+static const struct config_item_type uvcg_processing_grp_type = {
 	.ct_owner = THIS_MODULE,
 };
 
@@ -382,7 +382,7 @@ static ssize_t uvcg_default_camera_bm_controls_show(
 	NULL,
 };
 
-static struct config_item_type uvcg_default_camera_type = {
+static const struct config_item_type uvcg_default_camera_type = {
 	.ct_attrs	= uvcg_default_camera_attrs,
 	.ct_owner	= THIS_MODULE,
 };
@@ -394,7 +394,7 @@ static ssize_t uvcg_default_camera_bm_controls_show(
 	struct config_group	group;
 } uvcg_camera_grp;
 
-static struct config_item_type uvcg_camera_grp_type = {
+static const struct config_item_type uvcg_camera_grp_type = {
 	.ct_owner = THIS_MODULE,
 };
 
@@ -460,7 +460,7 @@ static ssize_t uvcg_default_camera_bm_controls_show(
 	NULL,
 };
 
-static struct config_item_type uvcg_default_output_type = {
+static const struct config_item_type uvcg_default_output_type = {
 	.ct_attrs	= uvcg_default_output_attrs,
 	.ct_owner	= THIS_MODULE,
 };
@@ -472,7 +472,7 @@ static ssize_t uvcg_default_camera_bm_controls_show(
 	struct config_group	group;
 } uvcg_output_grp;
 
-static struct config_item_type uvcg_output_grp_type = {
+static const struct config_item_type uvcg_output_grp_type = {
 	.ct_owner = THIS_MODULE,
 };
 
@@ -481,7 +481,7 @@ static ssize_t uvcg_default_camera_bm_controls_show(
 	struct config_group	group;
 } uvcg_terminal_grp;
 
-static struct config_item_type uvcg_terminal_grp_type = {
+static const struct config_item_type uvcg_terminal_grp_type = {
 	.ct_owner = THIS_MODULE,
 };
 
@@ -586,7 +586,7 @@ static void uvcg_control_class_drop_link(struct config_item *src,
 	.drop_link	= uvcg_control_class_drop_link,
 };
 
-static struct config_item_type uvcg_control_class_type = {
+static const struct config_item_type uvcg_control_class_type = {
 	.ct_item_ops	= &uvcg_control_class_item_ops,
 	.ct_owner	= THIS_MODULE,
 };
@@ -596,7 +596,7 @@ static void uvcg_control_class_drop_link(struct config_item *src,
 	struct config_group	group;
 } uvcg_control_class_grp;
 
-static struct config_item_type uvcg_control_class_grp_type = {
+static const struct config_item_type uvcg_control_class_grp_type = {
 	.ct_owner = THIS_MODULE,
 };
 
@@ -605,7 +605,7 @@ static void uvcg_control_class_drop_link(struct config_item *src,
 	struct config_group	group;
 } uvcg_control_grp;
 
-static struct config_item_type uvcg_control_grp_type = {
+static const struct config_item_type uvcg_control_grp_type = {
 	.ct_owner = THIS_MODULE,
 };
 
@@ -857,7 +857,7 @@ static void uvcg_streaming_header_drop_link(struct config_item *src,
 	NULL,
 };
 
-static struct config_item_type uvcg_streaming_header_type = {
+static const struct config_item_type uvcg_streaming_header_type = {
 	.ct_item_ops	= &uvcg_streaming_header_item_ops,
 	.ct_attrs	= uvcg_streaming_header_attrs,
 	.ct_owner	= THIS_MODULE,
@@ -901,7 +901,7 @@ static void uvcg_streaming_header_drop(struct config_group *group,
 	.drop_item		= uvcg_streaming_header_drop,
 };
 
-static struct config_item_type uvcg_streaming_header_grp_type = {
+static const struct config_item_type uvcg_streaming_header_grp_type = {
 	.ct_group_ops	= &uvcg_streaming_header_grp_ops,
 	.ct_owner	= THIS_MODULE,
 };
@@ -1150,7 +1150,7 @@ static ssize_t uvcg_frame_dw_frame_interval_store(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type uvcg_frame_type = {
+static const struct config_item_type uvcg_frame_type = {
 	.ct_attrs	= uvcg_frame_attrs,
 	.ct_owner	= THIS_MODULE,
 };
@@ -1419,7 +1419,7 @@ static ssize_t uvcg_uncompressed_guid_format_store(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type uvcg_uncompressed_type = {
+static const struct config_item_type uvcg_uncompressed_type = {
 	.ct_group_ops	= &uvcg_uncompressed_group_ops,
 	.ct_attrs	= uvcg_uncompressed_attrs,
 	.ct_owner	= THIS_MODULE,
@@ -1469,7 +1469,7 @@ static void uvcg_uncompressed_drop(struct config_group *group,
 	.drop_item		= uvcg_uncompressed_drop,
 };
 
-static struct config_item_type uvcg_uncompressed_grp_type = {
+static const struct config_item_type uvcg_uncompressed_grp_type = {
 	.ct_group_ops	= &uvcg_uncompressed_grp_ops,
 	.ct_owner	= THIS_MODULE,
 };
@@ -1619,7 +1619,7 @@ static struct uvcg_mjpeg *to_uvcg_mjpeg(struct config_item *item)
 	NULL,
 };
 
-static struct config_item_type uvcg_mjpeg_type = {
+static const struct config_item_type uvcg_mjpeg_type = {
 	.ct_group_ops	= &uvcg_mjpeg_group_ops,
 	.ct_attrs	= uvcg_mjpeg_attrs,
 	.ct_owner	= THIS_MODULE,
@@ -1663,7 +1663,7 @@ static void uvcg_mjpeg_drop(struct config_group *group,
 	.drop_item		= uvcg_mjpeg_drop,
 };
 
-static struct config_item_type uvcg_mjpeg_grp_type = {
+static const struct config_item_type uvcg_mjpeg_grp_type = {
 	.ct_group_ops	= &uvcg_mjpeg_grp_ops,
 	.ct_owner	= THIS_MODULE,
 };
@@ -1728,7 +1728,7 @@ static void uvcg_mjpeg_drop(struct config_group *group,
 	NULL,
 };
 
-static struct config_item_type uvcg_default_color_matching_type = {
+static const struct config_item_type uvcg_default_color_matching_type = {
 	.ct_attrs	= uvcg_default_color_matching_attrs,
 	.ct_owner	= THIS_MODULE,
 };
@@ -1740,7 +1740,7 @@ static void uvcg_mjpeg_drop(struct config_group *group,
 	struct config_group	group;
 } uvcg_color_matching_grp;
 
-static struct config_item_type uvcg_color_matching_grp_type = {
+static const struct config_item_type uvcg_color_matching_grp_type = {
 	.ct_owner = THIS_MODULE,
 };
 
@@ -2085,7 +2085,7 @@ static void uvcg_streaming_class_drop_link(struct config_item *src,
 	.drop_link	= uvcg_streaming_class_drop_link,
 };
 
-static struct config_item_type uvcg_streaming_class_type = {
+static const struct config_item_type uvcg_streaming_class_type = {
 	.ct_item_ops	= &uvcg_streaming_class_item_ops,
 	.ct_owner	= THIS_MODULE,
 };
@@ -2095,7 +2095,7 @@ static void uvcg_streaming_class_drop_link(struct config_item *src,
 	struct config_group	group;
 } uvcg_streaming_class_grp;
 
-static struct config_item_type uvcg_streaming_class_grp_type = {
+static const struct config_item_type uvcg_streaming_class_grp_type = {
 	.ct_owner = THIS_MODULE,
 };
 
@@ -2104,7 +2104,7 @@ static void uvcg_streaming_class_drop_link(struct config_item *src,
 	struct config_group	group;
 } uvcg_streaming_grp;
 
-static struct config_item_type uvcg_streaming_grp_type = {
+static const struct config_item_type uvcg_streaming_grp_type = {
 	.ct_owner = THIS_MODULE,
 };
 
@@ -2190,7 +2190,7 @@ static void uvc_attr_release(struct config_item *item)
 	NULL,
 };
 
-static struct config_item_type uvc_func_type = {
+static const struct config_item_type uvc_func_type = {
 	.ct_item_ops	= &uvc_item_ops,
 	.ct_attrs	= uvc_attrs,
 	.ct_owner	= THIS_MODULE,
-- 
1.9.1
