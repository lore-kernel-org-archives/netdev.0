From: Andy Fleming <afleming@gmail.com>
Subject: Re: SMSC 8720a/MDIO/PHY help.
Date: Fri, 15 Apr 2011 15:29:55 -0500
Message-ID: <BANLkTik7xeMnx0S2m0easY0hVT_UmomjzA@mail.gmail.com>
References: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E632@EXV1.corp.adtran.com>
	<1302729564.2742.28.camel@malcolm>
	<9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E8D4@EXV1.corp.adtran.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: michael@riesch.at, netdev@vger.kernel.org
To: ANDY KENNEDY <ANDY.KENNEDY@adtran.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:34726 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200Ab1DOUaw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 16:30:52 -0400
Received: by pvg12 with SMTP id 12so1240233pvg.19
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 13:30:52 -0700 (PDT)
In-Reply-To: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E8D4@EXV1.corp.adtran.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2011 at 4:38 PM, ANDY KENNEDY <ANDY.KENNEDY@adtran.com>=
 wrote:
>> -----Original Message-----
>> From: Michael Riesch [mailto:michael@riesch.at]
>> Sent: Wednesday, April 13, 2011 4:19 PM
>> To: netdev@vger.kernel.org
>> Cc: ANDY KENNEDY
>> Subject: Re: SMSC 8720a/MDIO/PHY help.
>>
>>
>> > If you have an idea of something for me to try, I'd love to
>> entertain
>> > it.
>>
>> I am rather new to PHYLIB, but these are my ideas:
>>
>> =A01) make sure phy_connect is executed (AFIAK called by MDIO bus
>> driver)
>
> Going through the phy.txt doc under Documentation/networking:
> PHY Abstraction Layer
> (Updated 2008-04-08)
> though it may be a bit out-of-date, I did see what you are talking ab=
out. =A0What I'm hung up on at the moment is the behavior of adjust_lin=
k(). =A0It appears that I only need to start the queues, though I don=92=
t know.
>
>>
>> =A02) maybe you need to call phy_start / phy_stop (AFAIK from the PH=
Y
>> driver's open / close function)
>
> Currently, when I do this I only get the call to adjust_link() over a=
nd over again.


=2E..this means that the state machine is running.  The PHY is polling
every couple seconds to report the current state. It calls
adjust_link() to keep the net_device up-to-date on that state. What
other behavior are you expecting to see?


Andy
