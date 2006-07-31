From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/4] kevent: core files.
Date: Mon, 31 Jul 2006 15:20:27 -0700 (PDT)
Message-ID: <20060731.152027.116353974.davem@davemloft.net>
References: <20060731194143.GA12569@2ka.mipt.ru>
	<20060731.150028.26276495.davem@davemloft.net>
	<200607311716.48455.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, drepper@redhat.com, zach.brown@oracle.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32908
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751426AbWGaWVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 18:21:13 -0400
To: bcook@bpointsys.com
In-Reply-To: <200607311716.48455.bcook@bpointsys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brent Cook <bcook@bpointsys.com>
Date: Mon, 31 Jul 2006 17:16:48 -0500

> There has to be some thread that is responsible for reading
> events. Perhaps a reasonable thing for a blocked thread that cannot
> process events to do is to yield to one that can?

The reason one decentralizes event processing into threads is so that
once they are tasked to process some event they need not be concerned
with event state.

They are designed to process their event through to the end, then
return to the top level and say "any more work for me?"
