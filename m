From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: b43: BCM 4331: MacBook 8,1: No connection after suspend
Date: Sat, 19 Nov 2011 21:14:22 +0100
Message-ID: <CACna6rxe7LVOr-nic8z4H38mYH41G5MM2AjECzCFDL+qvxfY+Q__49478.2509784729$1321733688$gmane$org@mail.gmail.com>
References: <20111118173242.GA2101@schottelius.org>
	<20111118173921.GB2101@schottelius.org>
	<4EC6B9E9.50204@broadcom.com>
	<4EC6BB5E.4010101@broadcom.com>
	<CACna6ryw9gC5CnY-ex45JFmQtXRxs8NX9ADkqVZrOj5CCtjiVw@mail.gmail.com>
	<20111119200234.GA2140@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Nico Schottelius <nico-linux-20111118@schottelius.org>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Arend van Spriel <arend@broadcom.com>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65456 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234Ab1KSUOX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2011 15:14:23 -0500
In-Reply-To: <20111119200234.GA2140@schottelius.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/19 Nico Schottelius <nico-linux-20111118@schottelius.org>:
> Rafa=C5=82 Mi=C5=82ecki [Sat, Nov 19, 2011 at 12:08:51AM +0100]:
>> > In brcmsmac we reprogram the PCI BAR windows upon resume. Not sure=
 if
>> > that is done or needed in bcma, but may be worth checking.
>>
>> Good point.
>>
>> Please reload b43 *and bcma*. Both drivers. Share your results.
>
> Well, 100 points for you!
>
> rmmod of b43 and bcma and modprobe of b43 afterwards restores
> the ability to connect!

Great! :)


> Btw, I've found another issue: The signal level seems to be set
> to 0 for all networks, thus wpa_supplicant does not select the
> best network (Follow the white rabbit! in my case). Thus
> I've used "select_network 9" to force connection to the right
> networt.

Sorry, you're probably missing two important patches:
b43: fill ctl1 word on all newer PHYs, fix PHY errors
b43: HT-PHY: report signal to mac80211
I believe both will appear in 3.2-rc3.

--=20
Rafa=C5=82
