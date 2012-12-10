From: Peter Hurley <peter@hurleysoftware.com>
Subject: netconsole fun
Date: Mon, 10 Dec 2012 09:17:13 -0500
Message-ID: <1355149033.3142.14.camel@thor>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout60.mail01.mtsvc.net ([216.70.64.8]:54779 "EHLO
	mailout60.mail01.mtsvc.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751781Ab2LJV3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 16:29:50 -0500
Received: from mailout39.mail01.mtsvc.net ([216.70.64.83] helo=n12.mail01.mtsvc.net)
	by mailout60.mail01.mtsvc.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.72)
	(envelope-from <peter@hurleysoftware.com>)
	id 1Ti4BA-00007e-B3
	for netdev@vger.kernel.org; Mon, 10 Dec 2012 09:17:56 -0500
Received: from n18.c08.mtsvc.net ([205.186.176.18]:51193)
	by n12.mail01.mtsvc.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <peter@hurleysoftware.com>)
	id 1Ti4AZ-00021G-32
	for netdev@vger.kernel.org; Mon, 10 Dec 2012 09:17:21 -0500
Received: from 68-189-242-29.dhcp.oxfr.ma.charter.com ([68.189.242.29]:50997 helo=[192.168.1.139])
	by n18.c08.mtsvc.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <peter@hurleysoftware.com>)
	id 1Ti4AU-0004qp-Su
	for netdev@vger.kernel.org; Mon, 10 Dec 2012 06:17:18 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that netpoll has been disabled for slaved devices, is there a
recommended method of running netconsole on a machine that has a slaved
device?

I ask because it seems pretty difficult to get netconsole running even
on a machine that has multiple physical interfaces, only one of which is
slaved.

I scoured the documentation but didn't find anything relevant (does
Documentation/networking/netconsole.txt need a patch?). AFAICT, the last
discussion ended here back in June '11
http://lkml.indiana.edu/hypermail/linux/kernel/1106.1/03185.html with
"Looks like we need to teach the tun-tap driver to support netpoll that
shouldn't be too hard. I'll send up a patch shortly
Neil"

Any help or pointers provided would be much appreciated.

Regards,
Peter Hurley
