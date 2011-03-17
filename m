From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-dev2.6] bxn2x: Fix location of PCI-ids defines
Date: Thu, 17 Mar 2011 08:10:46 -0700 (PDT)
Message-ID: <20110317.081046.193692423.davem@davemloft.net>
References: <1300364824.2090.57.camel@lb-tlvb-ariel.il.broadcom.com>
	<20110317.060650.226776465.davem@davemloft.net>
	<1300367613.31873.0.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55592
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753825Ab1CQPKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 11:10:08 -0400
In-Reply-To: <1300367613.31873.0.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Thu, 17 Mar 2011 15:13:33 +0200

> On Thu, 2011-03-17 at 06:06 -0700, David Miller wrote:
>> From: "Ariel Elior" <ariele@broadcom.com>
>> Date: Thu, 17 Mar 2011 14:27:04 +0200
>> 
>> > Signed-off-by: Ariel Elior <ariele@broadcom.com>
>> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>> 
>> Unless you intend to reference these symbols elsewhere in the
>> kernel, they should stay private in your driver.
>> 
> 
> The bnx2i will need it as well. Isn't it better to keep all the PCI IDs
> in the same global location?

If they are used in more than one driver, yes.
