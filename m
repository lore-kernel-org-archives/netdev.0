From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: don't sanity check non-existing TLV (NL
 compat)
Date: Mon, 17 Aug 2015 10:43:13 -0700 (PDT)
Message-ID: <20150817.104313.662767041806663657.davem@davemloft.net>
References: <1439813710-11322-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbbHQRnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 13:43:14 -0400
In-Reply-To: <1439813710-11322-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <richard.alpe@ericsson.com>
Date: Mon, 17 Aug 2015 14:15:10 +0200

> From: Richard Alpe <richard.alpe@ericsson.com>
> 
> A zero length payload means that no TLV (Type Length Value) data has
> been passed. Prior to this patch a non-existing TLV could be sanity
> checked with TLV_OK() resulting in random behavior where a user
> sending an empty message occasionally got a incorrect "operation not
> supported" message back.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>

Applied, thanks.
