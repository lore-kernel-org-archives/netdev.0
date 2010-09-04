From: Jiri Slaby <jirislaby@gmail.com>
Subject: bna: potential null dereference
Date: Sat, 04 Sep 2010 14:59:54 +0200
Message-ID: <4C8242CA.3020906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, "David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: ddutt@brocade.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

stanse found a potential null dereference:
bnad_cb_tx_cleanup
  -> struct bnad_unmap_q *unmap_q = tcb->unmap_q;
  -> -- tcb cannot be null now --
  -> if (!tcb || (!tcb->unmap_q))

The thing is I have no idea whether the second parameter of cleanup may
be null (move assignment after the check) or not (remove the check)

Could you fix that?

thanks,
-- 
js
