From: David Miller <davem@davemloft.net>
Subject: Re: [NET 00/06]: Increase number of possible routing tables
Date: Thu, 10 Aug 2006 23:44:14 -0700 (PDT)
Message-ID: <20060810.234414.89236927.davem@davemloft.net>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
	<44DC2617.7020200@tls.msk.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55012
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932308AbWHKGoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 02:44:04 -0400
To: mjt@tls.msk.ru
In-Reply-To: <44DC2617.7020200@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Tokarev <mjt@tls.msk.ru>
Date: Fri, 11 Aug 2006 10:39:19 +0400

> Patrick McHardy wrote:
> > These are the updated patches (against net-2.6.19) to increase the number
> > of possible routing tables to 2^32. They basically consist of four parts:
> > 
> > - Use u32 for routing table IDs everywhere inside the kernel
> 
> Just out of curiocity: why current limit of 2^31 isn't sufficient?
> Or am I missing the point?

The current limit is 256 because the table member of the struct
used to configure them is an 8-bit quantity.

That's the whole purpose of Patrick's patch set, to provide a new
optional attribute that allows specifying a 32-bit rather than
the 8-bit table ID.
