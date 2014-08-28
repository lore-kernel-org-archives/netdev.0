From: Sven Bachmann <dev@mcbachmann.de>
Subject: enhance sendto/recvfrom with Ethernet switch port
Date: Thu, 28 Aug 2014 10:39:40 +0200
Message-ID: <20140828103940.Horde.jf6ns7nEwCixTQixlWnCYA6@webmail.df.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed; DelSp=Yes
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay04.ispgateway.de ([80.67.31.38]:56970 "EHLO
	smtprelay04.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932699AbaH1Iqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 04:46:31 -0400
Received: from [80.67.16.118] (helo=webmailfront01.ispgateway.de)
	by smtprelay04.ispgateway.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <dev@mcbachmann.de>)
	id 1XMvF6-00060b-Ud
	for netdev@vger.kernel.org; Thu, 28 Aug 2014 10:39:41 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I tried to ask this question at Stackoverflow but they marked it as question
for Administrators and not for Programmers [1].

So maybe you could enlighten me. I have an AM335x board which uses the
integrated CPSW switch. This switch is supported by the current Linux  
tree [2].
Currently, the driver only uses the switch port where the frames are came in
and go out only internally.

My question is: is there already a common way to exchange the information
on which port a frame came in (recvfrom) and should go out (sendto) with a
userspace application which I could adapt for the CPSW driver?

For outgoing frames I'm using raw sockets, but for incoming frames UDP is
needed, so it should be possible to keep the information through the TCP/IP
stack.

Thanks for your hints and help!

[1]  
http://stackoverflow.com/questions/25528334/standard-way-under-linux-to-get-set-the-incoming-outgoing-ethernet-port-for-an-i
[2]  
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/drivers/net/ethernet/ti

Bye
   Sven
