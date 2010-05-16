From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rndis_host: Poll status channel before control channel
Date: Sat, 15 May 2010 22:54:12 -0700 (PDT)
Message-ID: <20100515.225412.108764724.davem@davemloft.net>
References: <1271718508.2197.12.camel@localhost>
	<20100512.234259.35058609.davem@davemloft.net>
	<1273930635.2564.23.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbrownell@users.sourceforge.net, john.carr@unrouted.co.uk,
	netdev@vger.kernel.org, vzeeaxwl@myfairpoint.net,
	herton@mandriva.com.br
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57196
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751348Ab0EPFyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 01:54:04 -0400
In-Reply-To: <1273930635.2564.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 15 May 2010 14:37:15 +0100

> On Wed, 2010-05-12 at 23:42 -0700, David Miller wrote:
>> From: Ben Hutchings <ben@decadent.org.uk>
>> Date: Tue, 20 Apr 2010 00:08:28 +0100
>> 
>> > Some RNDIS devices don't respond on the control channel until polled
>> > on the status channel.  In particular, this was reported to be the
>> > case for the 2Wire HomePortal 1000SW.
>> > 
>> > This is roughly based on a patch by John Carr <john.carr@unrouted.co.uk>
>> > which is reported to be needed for use with some Windows Mobile devices
>> > and which is currently applied by Mandriva.
>> > 
>> > Reported-by: Mark Glassberg <vzeeaxwl@myfairpoint.net>
>> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>> > Tested-by: Mark Glassberg <vzeeaxwl@myfairpoint.net>
>> > ---
>> > Note that this change hasn't yet been tested with any other RNDIS
>> > devices.  John, can you confirm whether this also handles the WinMob
>> > devices?
>> 
>> Still waiting for this to get tested.  Is there really nobody in the
>> world with RNDIS devices who can test this patch?  If so, maybe that's
>> a good reason to not apply it :-))))
> 
> This has been in Debian unstable since 1 May and I haven't seen any
> fall-out yet.  However I acknowledge that absence of evidence is not
> evidence of absence.

I think I'll toss it into net-next-2.6 and we'll see if any monsters
come out of that.

Thanks.
