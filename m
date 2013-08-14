From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: How to debug a driver which hangs (niu)?
Date: Wed, 14 Aug 2013 15:30:35 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1308141525110.25045@ask.diku.dk>
References: <CAHOfOo0kYpa3OtJ2w5xzdi=V6ccm9PKNJ8Pzj+7avNPmZDr9Gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linux Net-Dev Mailing List <netdev@vger.kernel.org>,
	Jesper Brouer <brouer@redhat.com>
To: Andrew Brooks <arb@sat.dundee.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:40792 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752803Ab3HNOCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Aug 2013 10:02:24 -0400
In-Reply-To: <CAHOfOo0kYpa3OtJ2w5xzdi=V6ccm9PKNJ8Pzj+7avNPmZDr9Gg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 12 Aug 2013, Andrew Brooks wrote:

> I'm using a network driver (niu) which regularly locks-up after
> printing the message "transmit timed out"
> (i.e. nothing else can be sent/received over that interface after the event).

What kernel version are you using?
I seem to remember to have fixed an issue with NIU driver, long time ago.


> Does anyone have any tips for helping me to debug this?

First thing you could do is to increase the message level in the driver (I 
remeber NIU uses these msglvl settings).

By command:
  ethtool -s eth0 msglvl $((0x7fff))

View the message level by command:
  ethtool eth0


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
