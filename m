From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add DEVTYPE support for Ethernet based devices
Date: Fri, 04 Sep 2009 22:55:24 -0700 (PDT)
Message-ID: <20090904.225524.13134133.davem@davemloft.net>
References: <1252125240.27694.5.camel@violet>
	<20090904.214615.198838334.davem@davemloft.net>
	<1252129940.27694.9.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	johannes@sipsolutions.net
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54760
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751089AbZIEFzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 01:55:09 -0400
In-Reply-To: <1252129940.27694.9.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Sat, 05 Sep 2009 07:52:20 +0200

>> > What is ugly about it. Do you have any other recommendation on how let
>> > userspace know what type of Ethernet device it is?
>> 
>> Well, for one thing, you're wasting 48 bytes on 64-bit when all you're
>> really intrested in is one string.
> 
> the integration with struct device has plenty of other advantages

Ok, this I agree with.
