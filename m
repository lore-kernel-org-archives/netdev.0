From: rask@sygehus.dk (Rask Ingemann Lambertsen)
Subject: net_device_stats questions
Date: Tue, 1 Apr 2003 19:00:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <586.817044723098$1049216660@news.gmane.org>
Reply-To: rask@sygehus.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi.

When updating net_device_stats.tx_bytes, should I just add skb->len (like e.g. tulip does) or add skb->len plus any padding (like e.g. 3c59x does)?

Let's say a TX heartbeat error occurs. Am I then supposed to update both net_device_stats.tx_errors and net_device_stats.tx_heartbeat_errors or just net_device_stats.tx_heartbeat_errors?

Which events should cause an update of net_device_stats.tx_aborted?

Regards,
Rask Ingemann Lambertsen
