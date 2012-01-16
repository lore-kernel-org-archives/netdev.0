From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] pch_gbe: Use a randomly generated MAC instead of failing probe
Date: Mon, 16 Jan 2012 16:20:45 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF47@saturn3.aculab.com>
References: <4F144B4F.7050905@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Alan Cox" <alan@linux.intel.com>,
	"Tomoya MORINAGA" <tomoya.rohm@gmail.com>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"David Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <jeffrey.t.kirsher@intel.com>,
	<paul.gortmaker@windriver.com>, <jdmason@kudzu.us>,
	<netdev@vger.kernel.org>
To: "Arjan van de Ven" <arjan@linux.intel.com>,
	"Darren Hart" <dvhart@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50487 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751886Ab2APQUq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 11:20:46 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06922-07 for <netdev@vger.kernel.org>;
 Mon, 16 Jan 2012 16:20:44 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <4F144B4F.7050905@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> the tricky thing with embedded hw like this is that all devices might
> end up with the same, read-only filesystem, so storing the 
> mac on the FS
> and then loading it from there into the HW is... suboptimal.
> 
> Would be very nice if busybox had a command that would check the mac
> from each IF, and created the random mac from userspace 
> automatically...

Since multiple interfaces on a single system are unlikely
to be connected to the same LAN segment, it doesn't really
matter if they use same MAC address.

For a long time sun solaris systems used the same MAC
address (based on the system id) on all their ethernet
interfaces.

But yes, you don't want a 'random' number generator that
might give the same value for cloned systems.
You also really want a 'manufacturer id' for 'random address'
so that they can't collide with anuything using real addresses.

	David
