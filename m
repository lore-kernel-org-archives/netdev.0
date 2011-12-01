From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 net-next 2/2] netem: add cell concept to simulate  special MAC behavior
Date: Thu, 1 Dec 2011 16:38:51 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEFA@saturn3.aculab.com>
References: <20111201082436.20f21e52@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>,
	"Hagen Paul Pfeifer" <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42443 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755251Ab1LAQi7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 11:38:59 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28732-05 for <netdev@vger.kernel.org>;
 Thu,  1 Dec 2011 16:38:55 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20111201082436.20f21e52@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> One idea to do small delays at higher speed is to insert 
> dummy pad frames into the device.
> It would mean generating garbage, but would allow for
> highly accurate fine grain delay.

Not a good idea.
They would have to be sent to a known MAC address
otherwise all the ethernet switches would forward them
on all output ports.

	David
