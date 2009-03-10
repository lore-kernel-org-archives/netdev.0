From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [net-next PATCH0/12] qlge: More features and cleanup.
Date: Tue, 10 Mar 2009 13:28:11 -0700
Message-ID: <20090310202811.GA8211@linux-ox1b.qlogic.org>
Reply-To: 1236632368-22079-1-git-send-email-ron.mercer@qlogic.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:34030 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753629AbZCJUby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 16:31:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> tatic int ql_configure_rings(struct ql_adapter *qdev)
>>  	 * completion handler rx_rings.
>>  	 */
>>  	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count
>>  	+ 1;
>> +	netif_set_gso_max_size(qdev->ndev, 65536);
>>  
>>  	for (i = 0; i < qdev->tx_ring_count; i++) {
>>  		tx_ring = &qdev->tx_ring[i];
>
>65536 (defined by GSO_MAX_SIZE) is the default and it's really a good
>idea to only use this override interface on chips that actaully have
>restrictions and can't use the default.
>
>I also don't see what this change had to do with adding TX
>multiqueue support :-)  It wasn't mentioned in the commit log
>message in any way either.  Please don't slip small things in
>like this.

Dave,

Thanks for clarifying this for me.  I'll drop this line in my next
series. I should have sent it as a separate (rejectable) patch.
I'll be more careful about that.

Ron




