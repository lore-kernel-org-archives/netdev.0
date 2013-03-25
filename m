From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 3/6] xen-netfront: frags -> slots in	xennet_get_responses
Date: Mon, 25 Mar 2013 14:25:06 +0000
Message-ID: <51505E42.3050403@citrix.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com> <1364209702-12437-4-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<annie.li@oracle.com>, <david.vrabel@citrix.com>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:12351 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758335Ab3CYOZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 10:25:08 -0400
In-Reply-To: <1364209702-12437-4-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/13 11:08, Wei Liu wrote:
> This function is in fact counting the ring slots required for responses.
> Separate the concepts of ring slots and skb frags make the code clearer, as
> now netfront and netback can have different MAX_SKB_FRAGS, slot and frag are
> not mapped 1:1 any more.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Makes sense.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
