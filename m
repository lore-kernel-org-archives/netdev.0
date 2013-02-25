From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/pasemi: Fix missing coding style
Date: Sun, 24 Feb 2013 20:52:16 -0500 (EST)
Message-ID: <20130224.205216.341922963875740910.davem@davemloft.net>
References: <1361746879-29261-1-git-send-email-s.syam@samsung.com>
	<20130224.201301.457851300548359313.davem@davemloft.net>
	<1361755409.2281.9.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: syamsidhardh@gmail.com, netdev@vger.kernel.org, olof@lixom.net
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932421Ab3BYBwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 20:52:17 -0500
In-Reply-To: <1361755409.2281.9.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 24 Feb 2013 17:23:29 -0800

> On Sun, 2013-02-24 at 20:13 -0500, David Miller wrote:
>> From: Syam Sidhardhan <syamsidhardh@gmail.com>
>> Date: Mon, 25 Feb 2013 04:31:19 +0530
>> 
>> > -             } else
>> > +             } else {
>> >                       freed = 2;
>> > +             }
>> 
>> Single line statements do not need braces.
> 
> I guess you didn't see the preceding block with braces.
> 
> CodingStyle:
> 
> This does not apply if only one branch of a conditional statement is a single
> statement; in the latter case use braces in both branches:

I did, and I don't think it's necessary in this case regardless
of what CodingStyle says, do you really honestly think it increases
readability enough to justify those two wasted vertical lines of
screen space?
