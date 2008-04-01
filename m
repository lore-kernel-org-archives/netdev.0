From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Subject: Setting alternate MAC addresses on e1000
Date: Tue, 01 Apr 2008 15:15:54 +0200
Message-ID: <47F2358A.8080505@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:36337 "EHLO welcomes-you.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754507AbYDANmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 09:42:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I know that quite a few e1000 experts are reading here, so I hope to 
have some luck here:

I need to reprogram the MAC addresses of several 82573E/L NICs. I tried 
the obvious approach first using ethtool -E to write the numbers into 
the first six bytes and this works quite ok [1], except that I need to 
specifically change the second MAC not necessarily the first one. This 
approach only changed the first NIC and left the second unchanged.

I've browsed http://download.intel.com/design/network/manuals/31608004.pdf
quite a bit, but except finding that I seem to need to set word 0x37 to 
point to 12 free bytes I have not come up with much. For example, I 
don't know where I would find those 12 free bytes.

Anyone with a different approach or a hint how to succeed?

TIA

Carsten

[1] Along the lines of
ethtool -E eth0 magic $MAGIC offset 0x0 value 0x${numbers[0]}
[...]
where magic is MAGIC=0x108c8086

However this does not work on eth1 :(
