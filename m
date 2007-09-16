From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS] Consolidate hashes creation in netdev_init()
Date: Sun, 16 Sep 2007 15:40:54 -0700 (PDT)
Message-ID: <20070916.154054.58447021.davem@davemloft.net>
References: <46EA4911.9070401@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	containers@lists.osdl.org, devel@openvz.org, dlezcano@fr.ibm.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:60141
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753432AbXIPWlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 18:41:03 -0400
In-Reply-To: <46EA4911.9070401@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 14 Sep 2007 12:40:49 +0400

> The dev_name_hash and the dev_index_hash are now booth kmalloc-ed
> (and each element is properly initialized as usually) so I think
> it's worth consolidating this code making it look nicer (and 
> saving 28 bytes of .text section ;) )
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.24, thanks Pavel.
