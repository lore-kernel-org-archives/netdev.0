From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH 5/6] net: qmi_wwan: document the qmi/raw_ip sysfs file
Date: Thu,  3 Dec 2015 19:24:22 +0100
Message-ID: <1449167063-22703-6-git-send-email-bjorn@mork.no>
References: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>,
	Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449167063-22703-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 Documentation/ABI/testing/sysfs-class-net-qmi | 23 +++++++++++++++++++=
++++
 1 file changed, 23 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-qmi

diff --git a/Documentation/ABI/testing/sysfs-class-net-qmi b/Documentat=
ion/ABI/testing/sysfs-class-net-qmi
new file mode 100644
index 000000000000..d240b7bf6587
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-net-qmi
@@ -0,0 +1,23 @@
+What:		/sys/class/net/<iface>/qmi/raw_ip
+Date:		Dec 2015
+KernelVersion:	4.4
+Contact:	Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
+Description:
+		Boolean.  Default: 'N'
+
+		Set this to 'Y' to change the network device link
+		framing from '802.3' to 'raw-ip'.
+
+		The netdev will change to reflect the link framing
+		mode.  The netdev is an ordinary ethernet device in
+		'802.3' mode, and the driver expects to exchange
+		frames with an ethernet header over the USB link. The
+		netdev is a headerless p-t-p device in 'raw-ip' mode,
+		and the driver expects to echange IPv4 or IPv6 packets
+		without any L2 header over the USB link.
+
+		Userspace is in full control of firmware configuration
+		through the delegation of the QMI protocol. Userspace
+		is responsible for coordination of driver and firmware
+		link framing mode, changing this setting to 'Y' if the
+		firmware is configured for 'raw-ip' mode.
--=20
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
