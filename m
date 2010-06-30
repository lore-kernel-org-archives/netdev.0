From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Extend Time Stamping
Date: Tue, 29 Jun 2010 22:37:15 -0700 (PDT)
Message-ID: <20100629.223715.216761137.davem@davemloft.net>
References: <cover.1277737222.git.richard.cochran@omicron.at>
	<20100629.153134.25136559.davem@davemloft.net>
	<20100630062806.GA3646@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59308
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751564Ab0F3FhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 01:37:04 -0400
In-Reply-To: <20100630062806.GA3646@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Wed, 30 Jun 2010 08:28:06 +0200

> On Tue, Jun 29, 2010 at 03:31:34PM -0700, David Miller wrote:
>> --------------------
>> By this I mean you should provide these inline helpers by default
>> then we can begin to put them into the drivers.
>> --------------------
>> 
>> This means no config option.
> 
> Okay, but what about the PHY time stamping hooks?
> 
> I anticipate that people will complain about the "performance penalty"
> of these extra checks in a critical path.

If you want to conditionalize the PHY hooks, fine.

But at a minimum, the software timestamping bits should be there by
default.
