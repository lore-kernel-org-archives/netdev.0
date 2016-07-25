From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix BH handling on socket backlog
Date: Mon, 25 Jul 2016 11:22:53 -0700 (PDT)
Message-ID: <20160725.112253.483808630563071321.davem@davemloft.net>
References: <a19b6088999a30defbfce748bc178935156a18a3.1469244527.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbcGYSWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 14:22:54 -0400
In-Reply-To: <a19b6088999a30defbfce748bc178935156a18a3.1469244527.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Sat, 23 Jul 2016 00:32:48 -0300

> Now that the backlog processing is called with BH enabled, we have to
> disable BH before taking the socket lock via bh_lock_sock() otherwise
> it may dead lock:
 ...
> Fixes: 860fbbc343bf ("sctp: prepare for socket backlog behavior change")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied and queued up for -stable, thanks.
