From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] Route ICMPv6 errors with the flow when
 ECMP in use
Date: Thu, 27 Oct 2016 11:23:31 -0400 (EDT)
Message-ID: <20161027.112331.1872860838376990837.davem@davemloft.net>
References: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jkbs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53722 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933351AbcJ0PXn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 11:23:43 -0400
In-Reply-To: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Mon, 24 Oct 2016 11:28:47 +0200

> However, for it to work IPv6 flow labels have to be same in both
> directions (i.e. reflected) or need to be chosen in a manner that
> ensures that the flow going in the opposite direction would actually
> be routed to a given path.

My understanding is that this is not really guaranteed, and that
entities are nearly encouraged to set the flow label in whatever
manner makes sense for their use case.

I think we really cannot have any kind of hard dependency on how
flow labels are set and used by the internet.
