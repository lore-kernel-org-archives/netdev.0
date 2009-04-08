From: "John Stoffel" <john@stoffel.org>
Subject: Re: usb_mon oops Re: tcpdump crashes 2.6.29.1 (and 2.6.29-rc5)
Date: Wed, 8 Apr 2009 09:20:54 -0400
Message-ID: <18908.42166.404232.721757@stoffel.org>
References: <18906.49779.243047.207639@stoffel.org>
	<20090407120022.GA6519@ff.dom.local>
	<18907.28788.965069.573489@stoffel.org>
	<20090407130403.e0061a8d.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "John Stoffel" <john@stoffel.org>,
	Jarek Poplawski <jarkao2@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Pete Zaitcev <zaitcev@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Mycroft.westnet.com ([216.187.52.7]:63505 "EHLO
	Mycroft.westnet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758915AbZDHNW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 09:22:29 -0400
In-Reply-To: <20090407130403.e0061a8d.zaitcev@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Pete> On Tue, 7 Apr 2009 11:25:40 -0400, "John Stoffel" <john@stoffel.org> wrote:
>> But I'm surprised that USB_MON would be the cause when it's a
>> networking tool which is starting up?  *shrug*

Pete> The libpcap supports usbmon. Perhaps it scans something.

Pete> The big problem with usbmon is, it has to trust what drivers
Pete> stuff into URBs. Bet it's your uvcvideo. A rough driver, that.

Well I think that usbmon is probably at fault here for trusting
drivers too much and not doing any sanity checking.  But I can try
removing the uvcvideo driver and seeing if I can get the system to
crash then.

I was busy last night and didn't have a chance to even touch the
system.  Hopefully more time tonight, but I'm not sure.

Thanks for the hints, I'll give them a whirl.

John

