From: David Hollis <dhollis@davehollis.com>
Subject: Re: Linksys Gigabit USB2.0 adapter (asix) regression
Date: Mon, 30 Jul 2007 14:27:54 -0400
Message-ID: <1185820074.8086.4.camel@dhollis-lnx.sunera.com>
References: <467915D9.3030900@slagter.name>
	<1182523020.4938.20.camel@dhollis-lnx.sunera.com>
	<467FF5DB.5090006@slagter.name>
	<1182923692.6644.4.camel@dhollis-lnx.sunera.com>
	<46ADAF1B.4060500@slagter.name>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Erik Slagter <erik@slagter.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:37946 "EHLO
	vms046pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966802AbXG3Slw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 14:41:52 -0400
Received: from smtp.davehollis.com ([72.64.253.72])
 by vms046.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JM000ASL8NLUFD0@vms046.mailsrvcs.net> for
 netdev@vger.kernel.org; Mon, 30 Jul 2007 13:28:35 -0500 (CDT)
In-reply-to: <46ADAF1B.4060500@slagter.name>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-07-30 at 11:27 +0200, Erik Slagter wrote:

> They are either garbled are they are not passed on the wire. The
> transmitted packets are shown by tshark, but a tshark run on "the other
> end of the line" does not show them.
> 
> Platform is indeed x86, to be precise: fedora 7, kernel 2.6.22-rc6, cpu
> pentium M, dell laptop inspiron 9300, ICH6.
> 
> If you want me to test something please yell, it's no trouble at all to
> change a few lines in the driver's source and recompile the module.
> 

Could you send me a complete dmesg dump when the driver is compiled with
DEBUG enabled (at least from then usb logs that the device was inserted
to the end).  I'll need to see what it reports the values of the
registers.

Have you tried using the F7 2.6.22 kernel?  I know that has worked fine
for me on my system.

> Please note I cannot send mail to you: "(conversation with
> dhollis.dyndns.org[71.251.104.159] timed out while sending MAIL FROM)"

I've fixed that issue so my mail delivery isn't sporadic.

-- 
David Hollis <dhollis@davehollis.com>

