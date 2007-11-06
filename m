From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH -net 2/2] Put proc_net_create() on death row
Date: Tue, 6 Nov 2007 13:32:24 +0000
Message-ID: <20071106133224.GA13120@infradead.org>
References: <20071106122350.GB6215@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:44794 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbXKFNcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 08:32:39 -0500
Content-Disposition: inline
In-Reply-To: <20071106122350.GB6215@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 06, 2007 at 03:23:50PM +0300, Alexey Dobriyan wrote:
> proc_net_create() stands on the way of shrinking the number of
> interfaces one can use for /proc files, namely, it uses ->get_info
> hook which will be converted, deprecated and deleted on its own
> schedule.

It's just a trivial helper, so please just remove it once you've
converted all users.

