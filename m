From: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Subject: [PATCH 0/5] wlcore: Fine-tuning for three function implementations
Date: Sun, 29 Oct 2017 21:10:34 +0100
Message-ID: <dc2b8a7c-b4a9-2f92-12b4-a1d0d6911d7c@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>, Iain Hunter <drhunter95-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        James Minor <james.minor-acOepvfBmUk@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Maxim Altshul <maxim.altshul-l0cyMroinI0@public.gmane.org>,
        Pieter-Paul Giesberts <pieter-paul.giesberts-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-GB
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Date: Sun, 29 Oct 2017 21:02:34 +0100

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (5):
  Use common error handling code in wlcore_nvs_cb()
  Delete an unnecessary check statement in wlcore_set_beacon_template()
  Return directly after a failed ieee80211_beacon_get()
    in wlcore_set_beacon_template()
  Use common error handling code in wlcore_set_beacon_template()
  Use common error handling code in wl1271_op_suspend()

 drivers/net/wireless/ti/wlcore/main.c | 51 ++++++++++++++++-------------------
 1 file changed, 23 insertions(+), 28 deletions(-)

-- 
2.14.3
