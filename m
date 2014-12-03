From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v4] rtnetlink: delay RTM_DELLINK notification
 until after ndo_uninit()
Date: Wed, 3 Dec 2014 22:25:10 +0000
Message-ID: <20141203222510.GB8822@casper.infradead.org>
References: <1417643184-23440-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46242 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbaLCWZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 17:25:14 -0500
Content-Disposition: inline
In-Reply-To: <1417643184-23440-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/14 at 01:46pm, Mahesh Bandewar wrote:
> The commit 56bfa7ee7c ("unregister_netdevice : move RTM_DELLINK to
> until after ndo_uninit") tried to do this ealier but while doing so
> it created a problem. Unfortunately the delayed rtmsg_ifinfo() also
> delayed call to fill_info(). So this translated into asking driver
> to remove private state and then query it's private state. This
> could have catastropic consequences.
> 
[...]
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Reported-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
> Cc: David S. Miller <davem@davemloft.net>

LGTM, thanks!

Acked-by: Thomas Graf <tgraf@suug.ch>
