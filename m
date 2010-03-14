From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool.h: Add "structs are public" disclaimer comment
Date: Sun, 14 Mar 2010 15:08:18 -0700 (PDT)
Message-ID: <20100314.150818.124884915.davem@davemloft.net>
References: <20100314014335.GA17208@serverengines.com>
	<20100313.181145.211264593.davem@davemloft.net>
	<1268583478.30289.94.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ajitk@serverengines.com, ajitkhaparde@gmail.com, jeff@garzik.org,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58574
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934132Ab0CNWH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Mar 2010 18:07:56 -0400
In-Reply-To: <1268583478.30289.94.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 14 Mar 2010 09:17:58 -0700

> On Sat, 2010-03-13 at 18:11 -0800, David Miller wrote:
>> For the millionth time, you cannot change these datastructures
>> like this without breaking all existing userspace applications
>> out there.
> 
> Maybe this might help reduce the broken record repetitiveness.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

That's rediculious.  Just about every single file in
include/linux/foo.h has similar stuff.

And we already have a way to document this, the fact that a header
file appears in include/linux/Kbuild shows that it provides userland
interfaces.

And your comment wouldn't help this person at all, they _KNEW_ it
changed userspace, because in the very next patch they patch the
userland tool to change the datastructures too!
