From: David Laight <David.Laight@ACULAB.COM>
Subject: Can I make USB IP addresses persist across unplug-replug events.
Date: Fri, 4 Apr 2014 13:47:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6EFE84@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54903 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752931AbaDDNtG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 09:49:06 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26830-05 for <netdev@vger.kernel.org>;
 Fri,  4 Apr 2014 14:48:58 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there a sane way to stop the local IP address (etc) associated
with a USB network interface being deleted when the USB card
is unplugged - so that everything will recover quickly when it is
plugged back in?

Maybe something horrid like master-slave bonding/teaming with a dummy
software interface which will silently discard tx traffic when the
usb interface is missing.

	David
