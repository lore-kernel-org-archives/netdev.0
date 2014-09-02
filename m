From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v4] lib/rhashtable: allow user to set the
 minimum shifts of shrinking
Date: Tue, 2 Sep 2014 12:04:18 +0100
Message-ID: <20140902110418.GC6778@casper.infradead.org>
References: <1409621339-6192-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33282 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749AbaIBLEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 07:04:21 -0400
Content-Disposition: inline
In-Reply-To: <1409621339-6192-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/14 at 09:28am, Ying Xue wrote:
> +	params->min_shift = max_t(size_t, params->min_shift,
> +				  (size_t)ilog2(HASH_MIN_SIZE));
> +

Sorry for being a pain here but the cast of ilog2() is not needed
and should be avoided. The whole point of max_t() is not requiring
these casts.
