From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] [ISDN] Documentation patchset
Date: Mon, 27 Apr 2009 05:39:02 -0700 (PDT)
Message-ID: <20090427.053902.262806706.davem@davemloft.net>
References: <cover.1240489461.git.keil@b1-systems.de>
	<20090427.031323.64748515.davem@davemloft.net>
	<200904271345.35345.karsten-keil@t-online.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: karsten-keil@t-online.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44019
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753741AbZD0MjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 08:39:09 -0400
In-Reply-To: <200904271345.35345.karsten-keil@t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <karsten-keil@t-online.de>
Date: Mon, 27 Apr 2009 13:45:34 +0200

> Hi David,
> 
> On Montag, 27. April 2009 12:13:23 David Miller wrote:
>> From: Karsten Keil <karsten-keil@t-online.de>
>> Date: Thu, 23 Apr 2009 14:24:21 +0200
>>
>> > Fixed one more typo and wrong From: lines.
>> >
>> > Add some useful documentation for the ISDN subsystem.
>> > Orignal patches are from Tilman Schmidt.
>> > I fixed some whitespace issues and added the URL for the CAPI 2.0 spec.
>>
>> This patch set does not apply at all to net-2.6
> 
> I do not understand this, the patches were created against Linus tree, but now 
> I checked out the net-2.6 tree and tried to apply them and it was successful, 
> no warnings, and indeed the affected files in Linus tree and in net-2.6 are 
> the same versions. To be sure that no MTA problem hit us, I used the mails
> which were sent back from the list.
> net-2.6 git tree was updated 15 minutes ago.
> 
> Here what I did:

Here they are in patchwork, they don't apply:

http://patchwork.ozlabs.org/patch/26362/
http://patchwork.ozlabs.org/patch/26363/
http://patchwork.ozlabs.org/patch/26361/

Oh I see what happened.

IT'S THOSE STUPID "Date:" fields you added to the body of 2 of those
patches.  It caused patchwork to put them in the wrong order when I
put them together into a bundle.

Don't add extra email header fields like that, please! :-)

I fixed it up and applied the patches.
