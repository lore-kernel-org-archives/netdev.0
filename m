From: "John Stoffel" <john@stoffel.org>
Subject: Re: usb_mon oops Re: tcpdump crashes 2.6.29.1 (and 2.6.29-rc5)
Date: Fri, 10 Apr 2009 11:18:35 -0400
Message-ID: <18911.25419.893747.465556@stoffel.org>
References: <18906.49779.243047.207639@stoffel.org>
	<20090407120022.GA6519@ff.dom.local>
	<18907.28788.965069.573489@stoffel.org>
	<20090407130403.e0061a8d.zaitcev@redhat.com>
	<18908.42166.404232.721757@stoffel.org>
	<20090408232344.afed8103.zaitcev@redhat.com>
	<18910.46709.707557.135033@stoffel.org>
	<20090410002435.52794220.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "John Stoffel" <john@stoffel.org>,
	Jarek Poplawski <jarkao2@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Pete Zaitcev <zaitcev@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Mycroft.westnet.com ([216.187.52.7]:51765 "EHLO
	Mycroft.westnet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S938680AbZDJPTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 11:19:52 -0400
In-Reply-To: <20090410002435.52794220.zaitcev@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Pete> On Thu, 9 Apr 2009 23:01:09 -0400, "John Stoffel" <john@stoffel.org> wrote:
>> Any suggestions of a known good state I should start bisection from?

Pete> No suggestions, sorry. The part of usbmon that peeks at DMA-ed
Pete> data wasn't touched since December 2006. It worked fine since
Pete> then, your oops is the first. So, I don't expect bisection to
Pete> help.  At best you're going to find the commit where uvcvideo
Pete> was merged.

I guess my next step would be to unload that module and see if the
crash happens while I have usbmon loaded.

Pete> The right way forward is to deduce what's going on, IMHO. Maybe
Pete> usbmon is trying to take an address in the GART aperture and
Pete> convert it into a struct page. Or the direction in URB
Pete> mismatches endpoint.  Or any number of other things.

I do have the Radeon driver installed, with DRI, etc.  

Pete> I'm working on it, but I'm not done with puzzling out the dmesg
Pete> you sent me, sorry again.

Let me know if you want me to put in debugging messages or try for
more netconsole output.  I built a bunch of kernels last night, but
ran out of reboot time (learning git...) to test them.  I figured I'd
go back to 2.6.26 and see if I had the problem there.  If not, it's a
good start for bisection.

I'll keep poking at this, though tax time is starting to fill my time
right now too.  :]

John

