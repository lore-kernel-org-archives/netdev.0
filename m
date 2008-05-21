From: Jon Masters <jonathan@jonmasters.org>
Subject: network interface *name* alias support?
Date: Wed, 21 May 2008 18:47:58 -0400
Message-ID: <1211410078.27149.70.camel@perihelion>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:54064 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753991AbYEUXRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 19:17:36 -0400
Received: from boston.jonmasters.org ([74.92.29.237] helo=[192.168.1.3])
	by dallas.jonmasters.org with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.60)
	(envelope-from <jonathan@jonmasters.org>)
	id 1Jyx6P-0006Hn-1O
	for netdev@vger.kernel.org; Wed, 21 May 2008 22:48:09 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to add support for network interface name aliases to the
kernel. For example, rather than simply "eth0", one might have:

eth0 -> eth_slot_0_0

And use either name for device configuration, etc. This should be pretty
easy, but I would like some comments - in particular, has this been done
already and I'm missing something?

Why is this useful? Say, for example that your a manufacturer building
machines using the latest DMI extension to SMBIOS that allows you to
specify what the physical ordering of interfaces is. Then, a
distribution might choose to configure based on the physical slot
ordering specified by the vendor - allowing for "rip and replace".

Jon.


