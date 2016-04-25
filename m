From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgbi: fix uninitialized flowi6
Date: Mon, 25 Apr 2016 16:21:15 -0400 (EDT)
Message-ID: <20160425.162115.128384058408635326.davem@davemloft.net>
References: <89cb4d2647db3bc922c7067d421e983a271483ca.1461322282.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	jejb@linux.vnet.ibm.com, martin.petersen@oracle.com,
	anish@chelsio.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964774AbcDYUVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 16:21:18 -0400
In-Reply-To: <89cb4d2647db3bc922c7067d421e983a271483ca.1461322282.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 22 Apr 2016 13:09:13 +0200

> ip6_route_output looks into different fields in the passed flowi6 structure,
> yet cxgbi passes garbage in nearly all those fields. Zero the structure out
> first.
> 
> Fixes: fc8d0590d9142 ("libcxgbi: Add ipv6 api to driver")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied.
