From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next v2 00/12] cdc_ncm: add buffer tuning and stats using ethtool
Date: Mon, 19 May 2014 09:36:30 +0200
Message-ID: <87egzqmd8h.fsf@nemi.mork.no>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>
	<20140516.224032.2301577488192248796.davem@davemloft.net>
	<87d2fcoqay.fsf@nemi.mork.no> <20140518011917.11270.qmail@stuge.se>
	<alpine.LNX.2.03.1405181155310.7743@gmail.com>
	<87vbt3m98p.fsf@nemi.mork.no> <5378E985.1040206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Stuge <peter@stuge.se>, Enrico Mioso <mrkiko.rs@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, alexey.orishko@gmail.com,
	oliver@neukum.org, David.Laight@aculab.com
To: Lars Melin <larsm17@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40310 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbaESHg5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 03:36:57 -0400
In-Reply-To: <5378E985.1040206@gmail.com> (Lars Melin's message of "Mon, 19
	May 2014 00:10:29 +0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lars Melin <larsm17@gmail.com> writes:

> Your target audience is embedded systems with limited cpu power and
> buffer memory, right?
> If so, then you can't expect them to have ethtool included and their
> developers are not likely to be happy over having to "waste" another
> 100KB in order to tune a 20KB driver.
> My vote goes for sysfs.

That's of course a very good point.

I will argue that you often need ethtool anyway for basic stuff like
forcing duplex/speed, enabling debug messages, turning on/off pause
frames etc.  But I don't doubt you know what you are talking about here
:-)  So I guess many small embedded devices don't include an ethtool
binary by default.  I do wonder how much we should adapt to that though=
?
I understand that you don't see it this way, but others might actually
see it as an advantage if we're forcing ethtool onto these devices...

Anyway, I'll start looking at an alternative sysfs implementation so we
can discuss this in terms of actual code.

But I will definitely leave the statistics in any case, so if you want
that then you will need ethtool.


Bj=C3=B8rn
