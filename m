From: David Miller <davem@davemloft.net>
Subject: Re: ieee802154: Source addr fix for dgram and some small at86rf230
 driver enhancements
Date: Wed, 27 Mar 2013 15:10:37 -0400 (EDT)
Message-ID: <20130327.151037.378525240140621201.davem@davemloft.net>
References: <1364337691-20163-1-git-send-email-stefan@datenfreihafen.org>
	<20130327.005318.1058473513349640907.davem@davemloft.net>
	<20130327185204.GH22584@novatech.datenfreihafen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	alan@signal11.us
To: stefan@datenfreihafen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906Ab3C0TKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 15:10:42 -0400
In-Reply-To: <20130327185204.GH22584@novatech.datenfreihafen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Schmidt <stefan@datenfreihafen.org>
Date: Wed, 27 Mar 2013 18:52:05 +0000

> Hello.
> 
> On Wed, 2013-03-27 at 00:53, David Miller wrote:
>> From: Stefan Schmidt <stefan@datenfreihafen.org>
>> Date: Tue, 26 Mar 2013 22:41:28 +0000
>> 
>> > Hello.
>> > 
>> > Second version. Changes since version 1:
>> > - Obey 80 chars rules
>> > - Switch logging mode to vdbg to avoid noise
>> > - Remove uneeded might_sleep()
>> > 
>> > Thanks Alan, Werner and Alex for the feedback.
>> > 
>> > I feel these are ready so I added DaveM and netdev to pick them up if they think
>> > the same.
>> 
>> All applied.
> 
> Thanks. That was quick. :)
> 
> I wonder what happened to the from of two of my commits. Looking at
> your repo they only show up my email address:
> 
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=1486774d69f6e58da16cdae8f17c77ec6569f711
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=028889b0b32064a3a23d6d8d4ef589a42a6d43c7
> 
> The one from Stephen is fine
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=6364e6ee788ae60f1c2de5c59e39adb157327e6c
> 
> The later as an explicit from as he was the author and I just the
> sender. For the two problematic ones git am should have picked up the
> normal mail from header, no?

I don't understand what the problem is.

The first two patches list you as the author, as that is the sender in
the From: field.

Oh, I see, the name, have a look at:

http://patchwork.ozlabs.org/patch/231579/

That's where I take the patches from, click on Download "mbox" and you'll
see that it gave me the headers as:

Date: Tue, 26 Mar 2013 12:41:30 -0000
From: stefan@datenfreihafen.org
