From: Michael Riesch <michael@riesch.at>
Subject: Driver for Asix AX88172A only?
Date: Fri, 01 Apr 2011 16:53:28 +0200
Message-ID: <20110401165328.20091msct39m3en4@webmail.df.eu>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay05.ispgateway.de ([80.67.31.99]:51854 "EHLO
	smtprelay05.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757521Ab1DAO7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 10:59:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Habidere,

I'm currently working on a driver for the Asix AX88172A  
USB-to-Ethernet chip[1]. It has an Ethernet PHY on-chip, but can work  
with an external PHY as well. Also, the chip provides various  
interfaces (SPI or I2C/UART) and GPIOs.

I have already tried out the asix.c mainline driver, which works with  
the evaluation board. As soon as you add the device-IDs, the driver  
works with the AX88172A's internal PHY. Because I would like to get it  
run with an external PHY (and use the SPI feature), I have also tried  
out the Asix vendor driver. It didn't like my 2.6.38-rc7+ kernel  
(2.6.35 worked), it does not have any "external PHY mode" and it  
supports SPI, I2C.. via ioctls.

Long story short, I want a nice mainline driver. I have heard there is  
some thinking about feeding the vendor code into the kernel[2], I  
would like to support that.

My TODO includes:
* support of an external PHY connected via MII
* support of the SPI interface via the SPI subsystem
* GPIO control via sysfs (is that a nice way?!)
* use of phylib

What do you think: should the mainline driver be adapted to support  
the AX88172A (with all his features) or a new driver for the AX88172A  
only should be created (probably based on the existing mainline driver).

Looking forward to your comments,
Michael

[1] http://www.asix.com.tw/products.php?op=pItemdetail&PItemID=97;71;101
[2] http://marc.info/?t=130013910200004&r=1&w=2


