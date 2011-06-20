From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC] Moving files around in drivers/net
Date: Mon, 20 Jun 2011 07:23:57 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1106200717100.10183@frira.zrqbmnf.qr>
References: <1306956602.32125.28.camel@Joe-Laptop>  <1306957998.3076.18.camel@jtkirshe-MOBL1>  <1306958478.32125.32.camel@Joe-Laptop>  <BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>  <1308186619.12377.23.camel@Joe-Laptop>
 <1308536729.22851.42.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:51047 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751222Ab1FTFX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 01:23:59 -0400
In-Reply-To: <1308536729.22851.42.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2011-06-20 04:25, Jeff Kirsher wrote:
>> pktgen in hamachi/yellowfin should be pkteng
>> 
>> I think it might be better if:
>> 
>> Things were more spelled out:
>>         pkteng should be packetengines
>
>That sounds fine.  I will make the change.

What's next, directory naming by Windows-originating coding styles -
"Drivers/Networking/Ethernet/Packet Engines/"?

>> And things maybe not spelled out
>>         ixp2000 might just be ixp (what not intel?:)

I don't understand your logic of doing pkteng -> packetengines
and ixp2000 -> ixp at the same time. I was quite thankful that
Linux's driver names were not (always) TLAs like in OpenBSD.

>While this is an Intel chip, the part was sold off and the driver is not
>maintained by Intel.  That is reason why it does not reside in
>the /driver/net/ethernet/intel/ directory.

And that's why it probably should not be attempted. The i in ixp
will remind us enough that it once was Intel's doing - just as
in ixgb, rtl*, atl*, etc. Separation by company seems unnecessary
to me.
