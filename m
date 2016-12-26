From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vif queue counters from int to long,[PATCH] vif queue
 counters from int to long
Date: Mon, 26 Dec 2016 11:35:10 -0500 (EST)
Message-ID: <20161226.113510.1343392262699950415.davem@davemloft.net>
References: <585D3E23.10509@greenhost.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.campbell@citrix.com,
        wei.liu2@citrix.com
To: mart@greenhost.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754445AbcLZQoS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2016 11:44:18 -0500
In-Reply-To: <585D3E23.10509@greenhost.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mart van Santen <mart@greenhost.nl>
Date: Fri, 23 Dec 2016 16:09:23 +0100

> This patch fixes an issue where counters in the queue have type int,
> while the counters of the vif itself are specified as long. This can
> cause incorrect reporting of tx/rx values of the vif interface.
> More extensively reported on xen-devel mailinglist.
> 
> Signed-off-by: Mart van Santen <mart@greenhost.nl>

Your subject line lacks a proper subsystem prefix, in this case
an appropriate one might be "xen-netback: "

Also, your patch was corrupted by your email client, transforming
TAB characters into spaces.  This makes the patch unusable.

Please read Documentation/email-clients.txt on how to fix this
and how to submit uncorrupted patches properly.

Email a test patch to yourself, and do not attempt to resend this
patch to the mailing list until you can successfully apply the test
patch you send to yourself.

Thanks.
