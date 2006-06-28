From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH, RFT] bcm43xx: AccessPoint mode
Date: Wed, 28 Jun 2006 21:39:41 +0200
Message-ID: <200606282139.41441.mb@bu3sch.de>
References: <200606191107.34602.mb@bu3sch.de> <fd8d0180606281227m309b0fcr94bc42c4c5247000@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	"Alexander Tsvyashchenko" <lists@ndl.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:56752
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751098AbWF1TkE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 15:40:04 -0400
To: "Francois Barre" <francois.barre@gmail.com>
In-Reply-To: <fd8d0180606281227m309b0fcr94bc42c4c5247000@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 28 June 2006 21:27, Francois Barre wrote:
> Hi all,
> 
> Sorry for answering years after the patch post, I didn't have time to
> test this take2 patch before. I had a first look at it a couple of
> days ago, but... you know, that was not my day.
> 
> > Well, it does not work 100%, but at least it's very promising.
> > We are able to create a bssid and correctly send beacon frames out.
> [...]
> 
> For my very own situation, that is :
> - Apple Mini with a BCM 4306 (BigEndian)
> - Linux/Win32 boxes with USB and PCMCIA wifi cards (mostly 802.11b usb
> at the moment)
> 
> Current status is this one :
> - master mode functionnal
> - dhcp serving, good uptime
> - no encryption, WEP or WPA of any kind tested yet
> - a nice 1.2MB/s bandwidth (I'm testing with a 802.11b at client side,
> and AFAIK, bcm43xx does not handle 802.11g yet, does it ?)
> 
> *BUT* a big issue : I got a per-connection hang-up at client side on
> strong workloads, for both win32 and linux client side, with my usb
> dongle (which is running ndiswrapper on *nux, sorry for that, I'm
> ashamed of it, silly me, I know, but well... No choice, and the device
> was given me free of charge so...).
> Typical scenario is a ssh session on one hand and a ftp transfer on
> the other. The ftp hangs, while the ssh session stays up and going.
> 
> I got no problem with the PCMCIA card (a rock-solid WG511T), on both
> linux and win32.
> 
> Of course, the bcm43xx does not say anything about this (if it had
> said so, I would have posted logs along with this complain), so my
> conclusion would be :
> 
> Why on earth is this a per-connection issue ? where do I miss
> something ? if I'm really missing packets on one connection, why is
> the other one continuing to live ? I may have forgotten a subtle
> detail of the TCP/IP behaviour here...

Well, I doubt it is a bcm43xx issue. But maybe. Not sure.

Do you run some QoS stuff? Some other quota stuff?

-- 
Greetings Michael.
