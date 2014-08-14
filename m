From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] net: xgene: Check negative return value of
 xgene_enet_get_ring_size()
Date: Thu, 14 Aug 2014 14:39:53 -0700 (PDT)
Message-ID: <20140814.143953.179653300813812591.davem@redhat.com>
References: <1408017582-1133-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kchudgar@apm.com, rapatel@apm.com,
	netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932143AbaHNVkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 17:40:00 -0400
In-Reply-To: <1408017582-1133-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu, 14 Aug 2014 13:59:42 +0200

> xgene_enet_get_ring_size() returns a negative value in case of an error,
> but its only caller in xgene_enet_create_desc_ring() currently uses the
> return value directly as u32. Instead, check for a negative value first and
> error out in case. Also move the call to xgene_enet_get_ring_size() before
> devm_kzalloc() so we don't need to free anything in the error path.
> 
> This fixes the following issue reported by the Coverity Scanner:
> 
> ** CID 1231336:  Improper use of negative value  (NEGATIVE_RETURNS)
> /drivers/net/ethernet/apm/xgene/xgene_enet_main.c: 596 in xgene_enet_create_desc_ring()
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
