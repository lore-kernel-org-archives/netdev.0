From: "Frank Schneider" <twodipu@hotmail.com>
Subject: Loop detected  - calling function from different modules
Date: Wed, 30 Aug 2006 22:58:17 +0200
Message-ID: <BAY101-F5AD1ED322334DFDAC9F22AB3E0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s25.bay0.hotmail.com ([65.54.246.97]:6814 "EHLO
	bay0-omc1-s25.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1751575AbWH3U6S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 16:58:18 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


hi all,

I am writing/customizing a network(wlan pc card) device driver for Linux 
kernel 2.6.12
Think about I have two modules e.g. ath_pci and wlan module.
I can call a function from a   .c file which is implemented in a  .c file in 
wlan module by using EXPORT_SYMBOL macro..

and i need to do same in reverse way, i.e. call a function from wlan module 
that is implemented in ath_pci module.

I did the same way and its making but when I do  make install its showing 
following error:

WARNING: Loop detected: /lib/modules/2.6.12/net/ath_pci.ko needs wlan.ko 
which needs ath_pci.ko again!

Please anybody tell how can I do this, any clue , please ?

thanx in advance

n.b. this question may consider as very naive since I am not good yet in 
kernel hacking.. !!!!

regards,
/Frank

_________________________________________________________________
Express yourself instantly with MSN Messenger! Download today it's FREE! 
http://messenger.msn.click-url.com/go/onm00200471ave/direct/01/

