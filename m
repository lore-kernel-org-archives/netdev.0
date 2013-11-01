From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 0/5] cdc_mbim + qmi_wwan trivial fixes
Date: Fri,  1 Nov 2013 14:18:51 +0100
Message-ID: <1383311936-20954-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series fixes three problems Oliver pointed out during the
review of the new huawei_cdc_ncm driver:
http://patchwork.ozlabs.org/patch/278903/

That innocent driver only used cdc_mbim as a blueprint, and
all the blame should really have gone to me....

I do have a similar fix for the manage_power issue in the
cdc-wdm USB class driver as well.  It will be submitted to
linux-usb as soon as Greg opens up his mailbox again :-)


Bj=C3=B8rn Mork (5):
  net: cdc_mbim: manage_power should always set needs_remote_wakeup
  net: qmi_wwan: manage_power should always set needs_remote_wakeup
  net: qmi_wwan: no need to check for resume if suspend exists
  net: cdc_mbim: no need to check for resume if suspend exists
  net: cdc_mbim: fixup error return value

 drivers/net/usb/cdc_mbim.c |   16 ++++++----------
 drivers/net/usb/qmi_wwan.c |   12 +++++-------
 2 files changed, 11 insertions(+), 17 deletions(-)

--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
