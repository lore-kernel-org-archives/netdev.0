From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: e1000: operation without eeprom?
Date: Mon, 28 Aug 2006 02:50:19 +0200
Message-ID: <20060828005019.GA31786@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tbm@cyrius.com, yt_lee@thecus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:59341 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1751293AbWH1AuV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 20:50:21 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

There are a couple of ARM boards out there with on-board e1000s but
without any kind of eeprom.  The boot loader and kernel board support
code have all the info necessary to configure the e1000, but the e1000
driver bombs out because there isn't an eeprom connected -- how are
we supposed to deal with this situation?


cheers,
Lennert
