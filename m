From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH net-next v2 00/12] cdc_ncm: add buffer tuning and stats
 using ethtool
Date: Sun, 18 May 2014 11:57:05 +0200 (CEST)
Message-ID: <alpine.LNX.2.03.1405181155310.7743@gmail.com>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no> <20140516.224032.2301577488192248796.davem@davemloft.net> <87d2fcoqay.fsf@nemi.mork.no> <20140518011917.11270.qmail@stuge.se>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-526419943-1400407026=:7743"
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, alexey.orishko@gmail.com,
	oliver@neukum.org, David.Laight@aculab.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:56636 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaERJ5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 05:57:03 -0400
In-Reply-To: <20140518011917.11270.qmail@stuge.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-526419943-1400407026=:7743
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

Or a set of module parameters, allowing them to be tuned at run-time via (e.g.) 
the param directory of the module in sysfs?
Yes, I imagine it's not the best solution.

On Sun, 18 May 2014, Peter Stuge wrote:

==Date: Sun, 18 May 2014 03:19:17
==From: Peter Stuge <peter@stuge.se>
==Reply-To: Bjørn Mork <bjorn@mork.no>, David Miller <davem@davemloft.net>,
==    netdev@vger.kernel.org, linux-usb@vger.kernel.org,
==    alexey.orishko@gmail.com, oliver@neukum.org, mrkiko.rs@gmail.com,
==    David.Laight@aculab.com
==To: Bjørn Mork <bjorn@mork.no>
==Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
==    linux-usb@vger.kernel.org, alexey.orishko@gmail.com, oliver@neukum.org,
==    mrkiko.rs@gmail.com, David.Laight@aculab.com
==Subject: Re: [PATCH net-next v2 00/12] cdc_ncm: add buffer tuning and stats
==    using ethtool
==
==Bjørn Mork wrote:
==> > Just make doubly sure that you will be ok, for a long time, with using
==> > the ethtool coalescing interface for configuring this because you'll
==> > really be stuck with this forever.
==> 
==> Yes, I am painfull aware of that.  So I was hoping someone would jump at
==> this and say something like "That's not the way to do it.  Use the foo
==> interface instead. It's made for stuff like this".
==
==sysfs?
==
==
==//Peter
==
--8323328-526419943-1400407026=:7743--
