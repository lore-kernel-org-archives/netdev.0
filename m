From: Jeff Garzik <jeff@garzik.org>
Subject: Re: ISDN testing
Date: Sun, 20 Apr 2008 21:43:57 -0400
Message-ID: <480BF15D.2090100@garzik.org>
References: <20080420223959.GA17998@havoc.gtf.org> <200804210205.38891.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de
To: Frans Pop <elendil@planet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43107 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752631AbYDUBoA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Apr 2008 21:44:00 -0400
In-Reply-To: <200804210205.38891.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frans Pop wrote:
> (Dropping private CCs.)
> 
> Jeff Garzik wrote:
>> - "isn't ISDN dead?"  Apparently, no it's not :)
>>
>> - "don't waste your time, drop these drivers and get mISDN into the
>>   kernel instead" -- based on discussion it does sound like mISDN should
>>   get into the kernel.  Until these drivers are dropped, however, my
>>   patches remain appropriate.
>>
>> And in case people are curious, #isdn-pci isn't ready for upstream yet
>> for two main reasons: (1) two drivers remain unconverted, and (2) none
>> of the changes have been tested, even once.
> 
> I have three different ISDN cards. However, since I've had ADSL since about 
> 3 years (on top of ISDN), I don't actually use it anymore.
> 
> I could be persuaded to do some testing though, or to donate some or all of 
> my cards for that purpose.
> 
> For testing I'd at least need somewhere to connect to, preferably in NL.
> I have no idea if I could still connect to my previous provider using ISDN. 
> The account was transferred to a different provider about 2 years ago, but 
> the mail accounts with the old provider are still active.
> 
> The cards I have are:
> - Teles 16.3 ISA -- worked way back when with Debian Woody
> - ITK ix1-micro 2.1 ISA
> - Eicon Diva 2.01 PCI
> 
> I also have a test box I can put them in :-)
> 
> Looks like I can still at least successfully load the hisax driver with 
> 2.6.18 for the Teles card. For the last two I'm not sure if I ever had them 
> working with Linux (or even if I tried).

Honestly, a module-load test on real hardware can give us some useful 
information, even if it's not connected to anything.

My changes are primarily in the probe-the-hardware area, so successfully 
making it past that new code would indeed be a useful data point.

Check out the kernel found in 'isdn-pci' branch of
git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/misc-2.6.git

Any help is certainly appreciated!

	Jeff




