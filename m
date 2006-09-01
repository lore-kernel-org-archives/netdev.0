From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh_table_clear() doesn't free stats
Date: Fri, 01 Sep 2006 01:34:34 -0700 (PDT)
Message-ID: <20060901.013434.07641591.davem@davemloft.net>
References: <44F7EF48.6090608@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, devel@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6819
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964898AbWIAIef (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 04:34:35 -0400
To: dev@openvz.org
In-Reply-To: <44F7EF48.6090608@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill Korotaev <dev@openvz.org>
Date: Fri, 01 Sep 2006 12:28:56 +0400

> neigh_table_clear() doesn't free tbl->stats.
> Found by Alexey Kuznetsov. Though Alexey considers this
> leak minor for mainstream, I still believe that cleanup
> code should not forget to free some of the resources :)
> 
> At least, this is critical for OpenVZ with virtualized
> neighbour tables.
> 
> Signed-Off-By: Kirill Korotaev <dev@openvz.org>

Applied, thanks a lot.
