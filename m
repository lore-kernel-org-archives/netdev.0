From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: tso: add support for IPv6
Date: Mon, 26 Oct 2015 22:24:46 -0700 (PDT)
Message-ID: <20151026.222446.1585829616685012620.davem@davemloft.net>
References: <1445803107-18513-1-git-send-email-emmanuel.grumbach@intel.com>
	<1445848289-26106-1-git-send-email-emmanuel.grumbach@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	egrumbach@gmail.com
To: emmanuel.grumbach@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbbJ0FIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 01:08:07 -0400
In-Reply-To: <1445848289-26106-1-git-send-email-emmanuel.grumbach@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Date: Mon, 26 Oct 2015 10:31:29 +0200

> Adding IPv6 for the TSO helper API is trivial:
> * Don't play with the id (which doesn't exist in IPv6)
> * Correctly update the payload_len (don't include the
>   length of the IP header itself)
> 
> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>

Applied to net-next, thanks.
