From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Subject: dev_kfree_skb{,irq,any}
Date: Fri, 30 Apr 2004 17:50:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <409275C5.8060008@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

what are the possible implications of calling dev_kfree_skb_irq from
non-interrupt context or calling dev_kfree_skb from interrupt context?

Looking at drivers/net, it seems dev_kfree_skb_irq is often called outside
an interrupt handler.

IIRC, dev_kfree_skb_any is the way to go if a certain routine can be
called both from interrupt context and outside it.

Regards,
Carl-Daniel
-- 
http://www.hailfinger.org/
