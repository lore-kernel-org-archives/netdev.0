From: Stephen Clark <sclark46@earthlink.net>
Subject: Trouble Shooting ipsec
Date: Mon, 07 Feb 2011 14:17:55 -0500
Message-ID: <4D504563.5010802@earthlink.net>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:35051 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754559Ab1BGTR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 14:17:57 -0500
Received: from [69.22.83.66] (helo=joker.seclark.com)
	by elasmtp-banded.atl.sa.earthlink.net with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.67)
	(envelope-from <sclark46@earthlink.net>)
	id 1PmWay-0002W0-Tx
	for netdev@vger.kernel.org; Mon, 07 Feb 2011 14:17:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

How do I find out what is happening to my packets thru my ipsec tunnel.
They just seem to disappear on the remote side.

I have successfully got the pings thru
when everything has an ipv6 address, but am not successful when trying
to connect two ipv4 lans across an ipv6 ipsec tunnel. All fw chains both 
4 and 6
are set to ACCEPT. NAT is turned off.

      eth0               eth1                                         
eth1                 eth0
10.1.254.254/17  2001:xxxx:1628::254 <----ipv6 internet -----> 
2001:xxxx:e334::254  10.0.254.254/17

12:00:02.296972 IP6 2001:xxxx:1628::254 > 2001:xxxx:e334::254: 
ESP(spi=0x07454bc3,seq=0x28b), length 132
12:00:03.308751 IP6 2001:xxxx:1628::254 > 2001:xxxx:e334::254: 
ESP(spi=0x07454bc3,seq=0x28c), length 132
12:00:04.296857 IP6 2001:xxxx:1628::254 > 2001:xxxx:e334::254: 
ESP(spi=0x07454bc3,seq=0x28d), length 132
12:00:05.293748 IP6 2001:xxxx:1628::254 > 2001:xxxx:e334::254: 
ESP(spi=0x07454bc3,seq=0x28e), length 132
12:00:06.296623 IP6 2001:xxxx:1628::254 > 2001:xxxx:e334::254: 
ESP(spi=0x07454bc3,seq=0x28f), length 132

I have posted to the ipsec-devel list and haven't gotten any responses. 
Also I have spent 2 days googling with
no results about the above setup. Is it even possible to tunnel ipv4 
packet thru an ipv6 ipsec tunnel?

Thanks,
Steve

-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)



