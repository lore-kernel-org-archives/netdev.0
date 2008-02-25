From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver updates
Date: Mon, 25 Feb 2008 17:59:04 -0500
Message-ID: <47C34838.3040502@garzik.org>
References: <OF5F5F5698.07AB615F-ON652573F6.00142D8A-652573F6.00147DC9@in.ibm.com><20080220.214651.235108740.davem@davemloft.net><8A71B368A89016469F72CD08050AD334026D6511@maui.asicdesigners.com> <20080220.221554.128587906.davem@davemloft.net> <8A71B368A89016469F72CD08050AD334026D652F@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59875 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761307AbYBYW7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 17:59:13 -0500
In-Reply-To: <8A71B368A89016469F72CD08050AD334026D652F@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray wrote:
>> From: "Divy Le Ray" <divy@chelsio.com>
>> Date: Wed, 20 Feb 2008 21:57:08 -0800
>>
>>> The driver is cxgb3 here, it uses LLTX.
>> That's extremely unfortunate, hopefully you can update it to
>> use a model like tg3 and others use.  LLTX is a lost cause
>> for hardware device drivers, and in fact we'd like to remove
>> it tree wide eventually.
> 
> It sounds like I messed up.
> cxgb3 does not use LLTX - The Chelsio driver does, thus should be
> converted.

So, it sounds like Krishna's patch is ok, because the race does not 
exist anymore in this driver?

	Jeff



