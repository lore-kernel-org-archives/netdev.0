From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] libcxgb: fix error check for ip6_route_output()
Date: Wed, 04 Jan 2017 13:26:23 -0500 (EST)
Message-ID: <20170104.132623.1717401011118715472.davem@davemloft.net>
References: <1483458948-13765-1-git-send-email-varun@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, swise@opengridcomputing.com,
        indranil@chelsio.com
To: varun@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58984 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935407AbdADS0Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 13:26:25 -0500
In-Reply-To: <1483458948-13765-1-git-send-email-varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varun Prakash <varun@chelsio.com>
Date: Tue,  3 Jan 2017 21:25:48 +0530

> ip6_route_output() never returns NULL so
> check dst->error instead of !dst.
> 
> Signed-off-by: Varun Prakash <varun@chelsio.com>

Applied, thanks.
