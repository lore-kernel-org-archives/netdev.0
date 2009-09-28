From: David Miller <davem@davemloft.net>
Subject: Re: tg3 and Broadcom PHY driver
Date: Mon, 28 Sep 2009 14:15:27 -0700 (PDT)
Message-ID: <20090928.141527.193009676.davem@davemloft.net>
References: <4ABE8862.3060308@embedded-sol.com>
	<20090928205226.GB12652@xw6200.broadcom.net>
	<4AC1223B.8070903@embedded-sol.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org
To: felix@embedded-sol.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40072
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753056AbZI1VPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 17:15:08 -0400
In-Reply-To: <4AC1223B.8070903@embedded-sol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Radensky <felix@embedded-sol.com>
Date: Mon, 28 Sep 2009 22:53:15 +0200

> Hi, Matt
> 
> Matt Carlson wrote:
>> On Sat, Sep 26, 2009 at 02:32:18PM -0700, Felix Radensky wrote:
>>   
>> Is the broadcom module also compiled into the kernel?
>>
>>   
> Yes.

I bet this is all because the tg3 driver is linked into the kernel
before the PHY layer and drivers subdirectory or something like that.

Link order determines the order in which built-in initializations
occur (within the same init type).
