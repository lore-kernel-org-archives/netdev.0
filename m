From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: HCI crash after tearing down ppp connection
Date: Wed, 28 Jan 2009 07:35:38 +0100
Message-ID: <1233124538.18259.30.camel@violet>
References: <1233082881.4455.14.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36013 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401AbZA1Gfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 01:35:46 -0500
In-Reply-To: <1233082881.4455.14.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

> I use /dev/rfcomm0 to connect to my cell phone, and then to the internet
> with ppp. Occasionally (two out of the three times I used it today)
> after I poff the connection the machine locks up. The second time I got
> a log, but because my display resolution is bad it mostly scrolled off,
> so I only got to see that hci was involved somehow :/
> 
> Anyone aware of any such issue? This is on
> 2.6.29-rc2-wl-11979-gc32422d-dirty (-rc2 + wireless bits).

I was assuming we fixed these, but we might ended with a new one since
the TTY is changing a little bit and the Bluetooth TTYs are special
since they are pure virtual TTYs. Can you reproduce this crash every
time or is it happening only now and then?

During the last weeks, I am chasing an USB issue with the USB anchors
and how we use it. You might be hitting the one.

Regards

Marcel


