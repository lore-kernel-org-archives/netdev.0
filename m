From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/1] pptp: Refactor the struct and macros of PPTP
 codes
Date: Mon, 15 Aug 2016 10:56:09 -0700 (PDT)
Message-ID: <20160815.105609.2284363778318727099.davem@davemloft.net>
References: <1471019448-3336-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: philipp@redfish-solutions.com, stephen@networkplumber.org,
	pshelar@nicira.com, tom@herbertland.com, xeb@mail.ru,
	netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753091AbcHOR4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 13:56:10 -0400
In-Reply-To: <1471019448-3336-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Sat, 13 Aug 2016 00:30:48 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> 1. Use struct gre_base_hdr directly in pptp_gre_header instead of
> duplicated members;
> 2. Use existing macros like GRE_KEY, GRE_SEQ, and so on instead of
> duplicated macros defined by PPTP;
> 3. Add new macros like GRE_IS_ACK/SEQ and so on instead of
> PPTP_GRE_IS_A/S and so on;
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied to net-next.
