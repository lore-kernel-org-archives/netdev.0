From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Help testing for USB ethernet/xHCI regression
Date: Thu, 30 Jan 2014 09:44:53 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6ACF20@AcuExch.aculab.com>
References: <22081260.RNay0J72dY@athas> <20140129215408.GC5991@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Mark Lord <mlord@pobox.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Sarah Sharp' <sarah.a.sharp@linux.intel.com>,
	"renevant@internode.on.net" <renevant@internode.on.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33363 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751445AbaA3JpW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 04:45:22 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06162-01 for <netdev@vger.kernel.org>;
 Thu, 30 Jan 2014 09:45:16 +0000 (GMT)
In-Reply-To: <20140129215408.GC5991@xanatos>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarah Sharp
> > Current issue is when plugging in the ax88179 there is lag when bringing the
> > interface up and a bunch of kernel messages:
> 
> With which kernel?

I saw similar issues testing some patches yesterday.
Both with the ax179_178a and smsx95xx cards (connected to xhci).
My kernel claims to be 3.13.0-dsl+ but it is lying since it was
updated from linus's tree earlier this week.
I'd not seen any similar delays until the last week or so.

The xhci controller I'm using is the Intel 'Panther Point' 8086:1e31
rev 4 (also says 8086:1e2d and 8086:1e26).

	David
