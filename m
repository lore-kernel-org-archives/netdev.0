From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc_ether: use USB_DEVICE_AND_INTERFACE_INFO for
 Novatel 551L/E362
Date: Fri, 09 Nov 2012 16:07:25 -0500 (EST)
Message-ID: <20121109.160725.1803281494550920517.davem@davemloft.net>
References: <1352398152.22225.14.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, aleksander@gnu.org, netdev@vger.kernel.org
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753443Ab2KIVHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 16:07:30 -0500
In-Reply-To: <1352398152.22225.14.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Thu, 08 Nov 2012 12:09:12 -0600

> Small cleanup.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> Cc: stable@vger.kernel.org

Don't do things like this, _please_.

A cleanup is absolutely not appropriate for -stable.   Yet you
tagged this as being destined for there.

What's more this screws up the second patch, which in fact could
be -stable material.  But I'm not going to apply it as it is
because it could have dependencies on this patch which as
states is not inappropriate for both 'net' and -stable.

I'm therefore tossing both of these changes, submit things properly
please.
