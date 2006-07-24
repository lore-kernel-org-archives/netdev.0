From: David Miller <davem@davemloft.net>
Subject: Re: RDMA will be reverted
Date: Mon, 24 Jul 2006 15:25:33 -0700 (PDT)
Message-ID: <20060724.152533.62664432.davem@davemloft.net>
References: <200607011626.04539.ak@suse.de>
	<1152119382.20248.51.camel@trinity.ogc.int>
	<1152121834.12325.10.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@opengridcomputing.com, ak@suse.de, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18317
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932285AbWGXWZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 18:25:23 -0400
To: swise@opengridcomputing.com
In-Reply-To: <1152121834.12325.10.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>
Date: Wed, 05 Jul 2006 12:50:34 -0500

> However, iWARP devices _could_ integrate with netfilter.  For most
> devices the connection request event (SYN) gets passed up to the host
> driver.  So the driver can enforce filter rules then.

This doesn't work.  In order to handle things like NAT and connection
tracking properly you must even allow ESTABLISHED state packets to
pass through netfilter.

Netfilter can have rules such as "NAT port 200 to 300, leave the other
fields alone" and your suggested scheme cannot handle this.
