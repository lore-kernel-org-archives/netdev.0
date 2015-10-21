From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] ARCNET: features and fixes
Date: Wed, 21 Oct 2015 07:46:53 -0700 (PDT)
Message-ID: <20151021.074653.1524280036733030215.davem@davemloft.net>
References: <1444993260-9667-1-git-send-email-m.grzeschik@pengutronix.de>
	<20151018.201942.595687134692884924.davem@davemloft.net>
	<20151019072427.GB23038@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, kernel@pengutronix.de
To: mgr@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752971AbbJUOa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 10:30:28 -0400
In-Reply-To: <20151019072427.GB23038@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Grzeschik <mgr@pengutronix.de>
Date: Mon, 19 Oct 2015 09:24:27 +0200

> Hi David,
> 
> On Sun, Oct 18, 2015 at 08:19:42PM -0700, David Miller wrote:
>> From: Michael Grzeschik <m.grzeschik@pengutronix.de>
>> Date: Fri, 16 Oct 2015 13:00:54 +0200
>> 
>> > This series includes some small fixes. The main changes are the correct
>> > xceiver handling (enable/disable) of the com20020 cards. The driver now handles
>> > link status change detection. The EAE PCI-ARCNET cards now make use of the
>> > rotary encoded subdevice indexing and got support for led triggers on transmit
>> > and reconnection events.
>> 
>> If you mix features and bug fixes, then it's ambiguous which tree these
>> changes should go into.
>> 
>> If it's just fixes, then it's clearly 'net',
>> 
>> But once you add feature changes and cleanups, then 'net' is not
>> appropriate.
>> 
>> Please split this up properly and submit things targetting the
>> correct GIT tree.
> 
> OK. You are right. Regarding this series I was a little bit imprecise
> about the topic. Actually only the first patch is no fix but adds code
> simplification. I forget that one in the last pull request. The other
> four are all adding features. The whole series sits on top of net-next.
> 
> Sorry for the confusion. I hope this series can be applied as is.

Please repost the series with the target tree properly specified in
your subject lines, the correct indication is:

	Subject: [PATCH net-next n/m] ...

Thanks.
