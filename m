From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic" trying
 toifenslave a second interface to my bond
Date: Mon, 04 May 2009 16:12:35 -0700 (PDT)
Message-ID: <20090504.161235.09270647.davem@davemloft.net>
References: <4086.1241463817@death.nxdomain.ibm.com>
	<20090504.120651.32573620.davem@davemloft.net>
	<1241478312.23179.5.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, paul@mad-scientist.net, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41411
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753108AbZEDXMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 19:12:41 -0400
In-Reply-To: <1241478312.23179.5.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 05 May 2009 00:05:12 +0100

> On Mon, 2009-05-04 at 12:06 -0700, David Miller wrote:
>> From: Jay Vosburgh <fubar@us.ibm.com>
>> Date: Mon, 04 May 2009 12:03:37 -0700
>> 
>> > Paul Smith <paul@mad-scientist.net> wrote:
>> > 
>> >>Hi Jay/David/etc.;
>> >>
>> >>This patch is critical for me to properly use mode 6 (balance-alb)
>> >>bonding; I assume it will be needed for others as well.  I haven't
>> >>checked to see if it's still necessary in 2.6.29/2.6.30, but I didn't
>> >>notice it going into the latest 2.6.27.22, released today.
>> >>
>> >>Is this still unofficial?  Is there an official patch on the horizon?
>> > 
>> > 	David, please apply and queue for -stable:
>> 
>> Greg just posted that there will be no further 2.6.27.x -stable
>> releases after the one he just made.
> 
> It's 2.6.28.x that he's dropping now
> <http://article.gmane.org/gmane.linux.kernel/831202>, not .27.x - he'll
> have to support the latter for years in SLES 11 anyway.

Yes he just corrected me about this in private email.
