From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IPv6: keep route for tentative address
Date: Mon, 24 May 2010 13:52:50 -0700 (PDT)
Message-ID: <20100524.135250.160201215.davem@davemloft.net>
References: <AANLkTin3CfATS0-ePL5WUSiuq0seRCQgM6xc-YwxpPEy@mail.gmail.com>
	<20100524113118.47cc9852@nehalam>
	<20100524184713.GA8627@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, emils.tantilov@gmail.com,
	netdev@vger.kernel.org, emil.s.tantilov@intel.com,
	stable@kernel.org
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755617Ab0EXUwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 16:52:40 -0400
In-Reply-To: <20100524184713.GA8627@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <greg@kroah.com>
Date: Mon, 24 May 2010 11:47:13 -0700

> On Mon, May 24, 2010 at 11:31:18AM -0700, Stephen Hemminger wrote:
>> Recent changes preserve IPv6 address when link goes down (good).
>> But would cause address to point to dead dst entry (bad).
>> The simplest fix is to just not delete route if address is
>> being held for later use.
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> (cherry picked from commit 93fa159abe50d3c55c7f83622d3f5c09b6e06f4b)
>> ---
>> Patch is for 2.6.34-stable (problem doesn't exist in earlier kernel)
> 
> Normally I wait for David to send networking patches for the stable
> trees, so I would like to get David's ack on these two before I am
> willing to apply them.

These two are fine to go to -stable, Greg please integrate.
