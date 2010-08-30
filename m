From: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: mac80211 using different tx queue for frames with same TID and RA
Date: Mon, 30 Aug 2010 16:01:12 +0200
Message-ID: <201008301601.12971.helmut.schaa@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

while debugging an issue in rt2x00 I've discovered that in some cases frames
with the same TID and RA end up in different tx queues (which causes problems
in rt2x00 when using aggregation).

Is this behavior expected and we need to handle that case in rt2x00 or is it
more likely a bug? At least I thought the select_queue implementation in
mac80211 was meant to always pick the same tx queue for skbs with the same
priority and hence it shouldn't happen that frames with the same TID are
queued into different tx queues.

This behavior seems to have changed already a while ago with the patch
"net: Use sk_tx_queue_mapping for connected sockets" (CC'ing Krishna & netdev).

Thanks,
Helmut
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
