From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] Ipvlan should return an error when an
 address is already in use.
Date: Fri, 09 Jun 2017 12:26:46 -0400 (EDT)
Message-ID: <20170609.122646.100677990071641882.davem@davemloft.net>
References: <20170101.222632.843875843588487678.davem@davemloft.net>
        <20170608201214.GB2553@templeofstupid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, netdev@vger.kernel.org
To: kjlx@templeofstupid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33552 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751560AbdFIQ0s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 12:26:48 -0400
In-Reply-To: <20170608201214.GB2553@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krister Johansen <kjlx@templeofstupid.com>
Date: Thu, 8 Jun 2017 13:12:14 -0700

> The ipvlan code already knows how to detect when a duplicate address is
> about to be assigned to an ipvlan device.  However, that failure is not
> propogated outward and leads to a silent failure.
> 
> Introduce a validation step at ip address creation time and allow device
> drivers to register to validate the incoming ip addresses.  The ipvlan
> code is the first consumer.  If it detects an address in use, we can
> return an error to the user before beginning to commit the new ifa in
> the networking code.
> 
> This can be especially useful if it is necessary to provision many
> ipvlans in containers.  The provisioning software (or operator) can use
> this to detect situations where an ip address is unexpectedly in use.
> 
> Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>

Ok, applied, thank you.
