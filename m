From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Logical interfaces (VLANs etc) flow control
Date: 12 Jul 2003 18:03:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3isq7ag14.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

probably a simple question: do we currently do any flow control for
logical subinterfaces (specifically 802.1q VLANs) similar to
netif_{stop,wake}_queue on the main (physical) device?

I notice "txqueuelen:0" on VLAN devices and vlan_dev_hard_start_xmit()
seems to not do any flow control, but I wonder if there is something
else?

The problem is I'm doing the same with Frame Relay, should I add a TX
queue to FR PVC devices and possibly stop/wake PVC device queue in sync
with physical device queue?

Possibly a pointer to faq or something?
-- 
Krzysztof Halasa
Network Administrator
