From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v2] rds: avoid potential stack overflow
Date: Wed, 11 Mar 2015 17:50:38 -0400
Message-ID: <20150311215038.GA13663@oracle.com>
References: <4321699.nNdBmxDHpu@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roland@purestorage.com,
	rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org,
	chien.yen@oracle.com, linux-arm-kernel@lists.infradead.org,
	David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18028 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbbCKVvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 17:51:17 -0400
Content-Disposition: inline
In-Reply-To: <4321699.nNdBmxDHpu@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/11/15 22:46), Arnd Bergmann wrote:
> 
> The rds_iw_update_cm_id function stores a large 'struct rds_sock' object
> on the stack in order to pass a pair of addresses. This happens to just
> fit withint the 1024 byte stack size warning limit on x86, but just
> exceed that limit on ARM, which gives us this warning:
  :
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

--Sowmini
