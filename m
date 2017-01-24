From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] net: ipv6: Improve user experience
 with multipath routes
Date: Tue, 24 Jan 2017 11:06:16 -0500 (EST)
Message-ID: <20170124.110616.2098461870069191491.davem@davemloft.net>
References: <1484892626-14257-1-git-send-email-dsa@cumulusnetworks.com>
        <90d6fdce-7780-b864-0e89-db262dec6fa1@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47910 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdAXQGg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 11:06:36 -0500
In-Reply-To: <90d6fdce-7780-b864-0e89-db262dec6fa1@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 20 Jan 2017 12:31:44 -0700

> BTW, I am in favor of not requiring a user API for this but just
> doing it. I can't imagine anyone working with multipath routes not
> wanting the efficiency of the RTA_MULTIPATH attribute. These patches
> require an API only because of the rule not to break userspace. If
> we conclude to just do it without an API, the multipath_add and
> multipath_del need to be modified to only send a notification once
> at the end of the actions.

After some consideration, I agree.

Please repost this series without the new netlink knob.

Thanks.
