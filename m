From: David Miller <davem@davemloft.net>
Subject: Re: bna: potential null dereference
Date: Sun, 12 Sep 2010 12:02:30 -0700 (PDT)
Message-ID: <20100912.120230.71108625.davem@davemloft.net>
References: <4C8242CA.3020906@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ddutt@brocade.com, rmody@brocade.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C8242CA.3020906@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jirislaby@gmail.com>
Date: Sat, 04 Sep 2010 14:59:54 +0200

> stanse found a potential null dereference:
> bnad_cb_tx_cleanup
>   -> struct bnad_unmap_q *unmap_q = tcb->unmap_q;
>   -> -- tcb cannot be null now --
>   -> if (!tcb || (!tcb->unmap_q))
> 
> The thing is I have no idea whether the second parameter of cleanup may
> be null (move assignment after the check) or not (remove the check)
> 
> Could you fix that?

Since the Brocade folks can't be bothered to fix this for more than
a week I'll take care of this, thanks Jiri.
