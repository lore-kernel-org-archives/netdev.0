From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: testing and validating 64-bit addressing.
Date: Mon, 18 Nov 2013 10:24:44 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B742C@saturn3.aculab.com>
References: <CAJ3bTp6pjy7PFbgAfoXoisue8xAeWA0bxxDPYY01QZN1iCX=rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "Rayagond K" <rayagond@vayavyalabs.com>,
	"netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47297 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750836Ab3KRKZy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 05:25:54 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09139-04 for <netdev@vger.kernel.org>;
 Mon, 18 Nov 2013 10:25:51 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <CAJ3bTp6pjy7PFbgAfoXoisue8xAeWA0bxxDPYY01QZN1iCX=rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I have one Ethernet card which supports 64-bit DMA addressing and I
> need to implement this feature and test it.
...
> 3. Installed the 64-bit operating system on 64-bit architecture -
> Fedora 15, 64 bit os , LINUX 3.8.0 kernel, Intel dual core processor,
> 4GB RAM.
...
> 1. Why are we always getting 33-bit address only ?

Because the physical memory is aligned to the bottom of the
physical memory map.
The only reason you see addresses above 4B is that there
is a great big address block (typically from 3G or 3.5G) reserved
for PCI devices.

	David
