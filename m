From: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH 12/16] NFC: remove unnecessary break after goto
Date: Mon, 14 Jul 2014 18:36:35 +0200
Message-ID: <1405355799-7691-3-git-send-email-fabf@skynet.be>
References: <1405355799-7691-1-git-send-email-fabf@skynet.be>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405355799-7691-1-git-send-email-fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
---
 net/nfc/digital_dep.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/nfc/digital_dep.c b/net/nfc/digital_dep.c
index 171cb99..37deb17 100644
--- a/net/nfc/digital_dep.c
+++ b/net/nfc/digital_dep.c
@@ -457,12 +457,10 @@ static void digital_tg_recv_dep_req(struct nfc_digital_dev *ddev, void *arg,
 		pr_err("Received a ACK/NACK PDU\n");
 		rc = -EINVAL;
 		goto exit;
-		break;
 	case DIGITAL_NFC_DEP_PFB_SUPERVISOR_PDU:
 		pr_err("Received a SUPERVISOR PDU\n");
 		rc = -EINVAL;
 		goto exit;
-		break;
 	}
 
 	skb_pull(resp, size);
-- 
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
