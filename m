From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: initialise session's refcount before making
 it reachable
Date: Mon, 28 Aug 2017 11:29:37 -0700 (PDT)
Message-ID: <20170828.112937.1045244252909820285.davem@davemloft.net>
References: <f37a31f7fbfa4c02c4a263672f86eac4e80be272.1503670839.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45260 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdH1S3i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 14:29:38 -0400
In-Reply-To: <f37a31f7fbfa4c02c4a263672f86eac4e80be272.1503670839.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 25 Aug 2017 16:22:17 +0200

> Sessions must be fully initialised before calling
> l2tp_session_add_to_tunnel(). Otherwise, there's a short time frame
> where partially initialised sessions can be accessed by external users.
> 
> Fixes: dbdbc73b4478 ("l2tp: fix duplicate session creation")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks.
