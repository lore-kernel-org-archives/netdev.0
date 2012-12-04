From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] Remove __dev* markings from the networking drivers
Date: Tue, 04 Dec 2012 13:17:26 -0500 (EST)
Message-ID: <20121204.131726.103739824056368439.davem@davemloft.net>
References: <20121203202743.GA29451@kroah.com>
	<20121203.153623.958379034481583512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wfp5p@virginia.edu
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723Ab2LDSR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 13:17:28 -0500
In-Reply-To: <20121203.153623.958379034481583512.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 03 Dec 2012 15:36:23 -0500 (EST)

> From: Greg KH <gregkh@linuxfoundation.org>
> Date: Mon, 3 Dec 2012 12:27:43 -0800
> 
>> Here's a pull request for all of Bill's __dev* removal patches for the
>> networking drivers, based on net-next.  I'll send out a separate one for
>> the wireless drivers in case those want to go through John's tree
>> 
>> If I should rework these in any way, please let me know.
> 
> Pulled, thanks Greg.

I had a reason to go look in detail at the changes in here.

It seemse the function declarations were not properly reformatted
after the __dev* tags were removed.  You can't just search and replace
this kind of stuff.  The result looks terrible.

Greg please check for things like this next time you send me changes
written by someone else.

Thanks.
