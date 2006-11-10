From: Jonathan Day <imipak@yahoo.com>
Subject: Questions regarding network drivers
Date: Thu, 9 Nov 2006 19:06:00 -0800 (PST)
Message-ID: <771883.63085.qm@web31512.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from web31512.mail.mud.yahoo.com ([68.142.198.141]:54664 "HELO
	web31512.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1424242AbWKJDGC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 22:06:02 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've got an interesting problem to contend with and
need some advice from the great wise ones here.

First of all, is it possible (and/or "reasonable
practice") when developing a network driver to do
zero-copy transfers between main memory and the
network device?

Secondly, the network device is only designed to work
with short packets and I really want to keep the
throughput up. My thought was that if I fired off an
interrupt then transfer a page of data into an area I
know is safe, the kernel will have enough time to find
a new safe area and post the address before the next
page is ready to send.

Can anyone suggest why this wouldn't work or, assuming
it can work, why this would be a Bad Idea?

Lastly, assuming my sanity lasts that long, would I be
correct in assuming that the first step in the process
of getting the driver peer-reviewed and accepted would
be to post the patches here?

Thanks for any help,

Jonathan Day



 
____________________________________________________________________________________
Yahoo! Music Unlimited
Access over 1 million songs.
http://music.yahoo.com/unlimited
