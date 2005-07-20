From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/8][ATM]: [zatm] eliminate kfree warning (from Tobias
 Hirning <sskyman@web.de>)
Date: Wed, 20 Jul 2005 11:56:30 -0700 (PDT)
Message-ID: <20050720.115630.48529801.davem@davemloft.net>
References: <200507192044.j6JKirFb027183@ginger.cmf.nrl.navy.mil>
	<20050720071919.GV4740@sunsite.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jakub@redhat.com
In-Reply-To: <20050720071919.GV4740@sunsite.mff.cuni.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jakub Jelinek <jakub@redhat.com>
Date: Wed, 20 Jul 2005 09:19:20 +0200

> This can't be right.  zatm_dev->mbx_start[i] is allocated with:

Correct, Francois posted a much better fix and I'll put
that into my tree.
