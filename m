From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: net/usb/ax88179_178a driver broken in linux-3.12
Date: Wed, 20 Nov 2013 09:54:02 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7439@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B742F@saturn3.aculab.com><528A9A36.50903@pobox.com><AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com> <20131119.161313.743887333007019981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <mlord@pobox.com>, <eric.dumazet@gmail.com>,
	<ming.lei@canonical.com>, <netdev@vger.kernel.org>,
	"Sarah Sharp" <sarah.a.sharp@linux.intel.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33283 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752433Ab3KTJyv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 04:54:51 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02009-04 for <netdev@vger.kernel.org>;
 Wed, 20 Nov 2013 09:54:46 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131119.161313.743887333007019981.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Of David Miller
> > From: "David Laight" <David.Laight@ACULAB.COM>
> > Date: Tue, 19 Nov 2013 10:04:11 -0000
> 
> > There is a patch to xhci-ring.c that should fix the SG problem.
> > http://www.spinics.net/lists/linux-usb/msg97176.html
> >
> > I think it should apply to the 3.12 sources.
> 
> David, please get this into Linus's tree and queued up for -stable
> as soon as possible, thank you.

What do I have to do to expedite it?
I thought that Sarah would have to push the patch through.

It might be necessary to limit the number of SG fragments that
the mass storage (etc) can generate to 63 (from unlimited).
That should be a 1 line change somewhere.

	David
