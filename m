From: jamal <hadi@cyberus.ca>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Thu, 06 Jul 2006 09:03:38 -0400
Message-ID: <1152191018.5103.48.camel@jzny2>
References: <1152033116.5276.22.camel@jzny2>
	 <1152040839.5276.25.camel@jzny2>
	 <20060705.112237.41652489.davem@davemloft.net> <44AC05A8.9030503@intel.com>
	 <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, greearb@candelatech.com, john.ronciak@intel.com,
	Robert.Olsson@data.slu.se, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:48361 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1030253AbWGFNDo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 09:03:44 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FyTWE-0003xL-6K
	for netdev@vger.kernel.org; Thu, 06 Jul 2006 09:03:46 -0400
To: Krzysztof Oledzki <olel@ans.pl>
In-Reply-To: <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-05-07 at 22:45 +0200, Krzysztof Oledzki wrote:
> 
> On Wed, 5 Jul 2006, Auke Kok wrote:
> 
> > David Miller wrote:
> >> From: jamal <hadi@cyberus.ca>
> >> Date: Tue, 04 Jul 2006 15:20:39 -0400
> >> 
> >>> BTW, As an addendum this default behavior changed around 2.6.16 it
> >>> seems.
> >> 
> >> Flow control has been on by default in the tg3 driver since the
> >> beginning, 

Are you sure about this Dave?;-> because I do have a tg3 on my laptop.

hadi@jzny2:~/Desktop/maemo$ sudo ethtool -a eth0
Pause parameters for eth0:
Autonegotiate:  on
RX:             off
TX:             off

hadi@jzny2:~/Desktop/maemo$ uname -a
Linux jzny2 2.6.16 #6 Fri Jun 9 15:29:40 EDT 2006 i686 GNU/Linux
hadi@jzny2:~/Desktop/maemo$

Maybe it is read from the eeprom and mine has it off?

> maybe e1000 only recently started to behave that way
> >> but it's the right thing to do IMHO.
> >

I will continue testing when i get proper hardware and post. And if only
Robert and I are whining about this, we are adults and we can turn it
off. I never tried it with large packets, so it may be helpful there
for forwarding.

Again, note that: It is consuming > 10% (13-15% range) of my bandwidth.
Granted that is at high speeds with small packets so may not be
reflective of 96% of the world. But that would be > 50kpps of my
forwarding capacity being chewed unreasonably. So Auke, did you say
"performance" was what people mostly bitched about? ;->

> > As said earlier, e1000 always honors the EEPROM setting for this, which has 
> > been _on_ by default for all cards (AFAIK, that is).
> 

It has _never ever_ worked on e1000 for as long as i have used e1000. If
it was intended to work, it must have been fixed in 2.6.16. So it is new
behavior.

> I'm not sure:
> 
> root@r1:~# mii-tool -v eth0

Try ethtool -a eth0 to read and -A to set.

cheers,
jamal

