From: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/2] net: usb: qmi_wwan: add qmap mux protocol support
Date: Fri, 24 Mar 2017 14:22:44 +0100
Message-ID: <1490361766-24114-1-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds support for qmap mux protocol available in recent
Qualcomm based modems.

The qmap mux protocol can be used for multiplexing data packets in
order to have multiple ip streams through the same physical device.

Two new sysfs files are added for adding/removing the qmap mux based
interfaces (named qmimux):

/sys/class/net/<iface>/qmi/add_mux
/sys/class/net/<iface>/qmi/del_mux

Main patch author is Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

An userspace implementation of the qmi requests needed to support
multiple ip streams is already available (namely libqmi since
version 1.18.0).

The qmap mux feature has been recently implemented in Codeaurora
gobinet out-of-kernel driver that was the inspiration for this
development.

Tests have been performed with Telit LE922A6 (PID 0x1040)

Daniele Palmas (2):
  net: usb: qmi_wwan: add qmap mux protocol support
  Documentation: ABI: testing: sysfs-class-net-qmi: add new qmap mux
    files description

 Documentation/ABI/testing/sysfs-class-net-qmi |  27 +++
 drivers/net/usb/qmi_wwan.c                    | 317 +++++++++++++++++++++++++-
 2 files changed, 343 insertions(+), 1 deletion(-)

-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
