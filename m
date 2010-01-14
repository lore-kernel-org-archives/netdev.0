From: David Miller <davem@davemloft.net>
Subject: Re: [ISDN] proc_fops: convert drivers/isdn/ to seq_file
Date: Thu, 14 Jan 2010 03:01:15 -0800 (PST)
Message-ID: <20100114.030115.95450487.davem@davemloft.net>
References: <20100110.132931.232879311.davem@davemloft.net>
	<201001140237.08389.keil@b1-systems.de>
	<20100113.202952.01130510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tilman@imap.cc, adobriyan@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: keil@b1-systems.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40495
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755467Ab0ANLBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 06:01:07 -0500
In-Reply-To: <20100113.202952.01130510.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 13 Jan 2010 20:29:52 -0800 (PST)

> From: Karsten Keil <keil@b1-systems.de>
> Date: Thu, 14 Jan 2010 02:37:07 +0100
> 
>>  drivers/isdn/hardware/eicon/divasproc.c |  198 
>> ++++++++++++++-----------------
> 
> Long lines broken up, again...

And just in case there is any confusion.

Take a look at:

	http://patchwork.ozlabs.org/patch/42844/

That patch is mangled, and that's what Karsten sent to the list.

Diff hunk header lines that quote the function which is being modified
are chopped up into multiple lines:

--------------------
@@ -2229,59 +2230,37 @@ static void lower_callback(unsigned int cmd, u32 
contr, void *data)
--------------------

That is corrupted, and it won't apply.  And that's what landed in my
mailbox for Karsten's posting too, so it's not like patchwork put that
newline there.

The amount of time and effort being expended for this trivial patch
submission is staggering!

