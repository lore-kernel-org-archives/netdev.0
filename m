From: "Srivats P" <Srivats.P@conexant.com>
Subject: RE: [PATCH] iproute2: Fix no default display of ip4ip6 tunnels
Date: Tue, 24 Feb 2009 14:21:04 +0530
Message-ID: <F33E0C3C2876A544ABD34CFBE345A4A40211E428E8@NDMBX01.bbnet.ad>
References: <F33E0C3C2876A544ABD34CFBE345A4A40211E426D0@NDMBX01.bbnet.ad>
 <20090219085209.4dc6bce5@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnxtsmtp5.conexant.com ([198.62.9.40]:46369 "EHLO
	cnxtsmtp5.conexant.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbZBXIu1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 03:50:27 -0500
Received: from CPS (wsmx1.nb.conexant.com [157.152.185.16]) (using TLSv1 with cipher RC4-MD5 (
 128/128 bits)) (No client certificate requested) by cnxtsmtp5.conexant.com (Tumbleweed MailGate
 3.6.1) with ESMTP id 2247D240DA9 for <netdev@vger.kernel.org>; Tue, 24 Feb 2009 00:50:24 -0800 (
 PST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
Stephen,

Awaiting your response.

Regards,
Srivats

-----Original Message-----
From: Srivats P 
Sent: Friday, February 20, 2009 10:20 AM
To: 'Stephen Hemminger'
Cc: netdev@vger.kernel.org
Subject: RE: [PATCH] iproute2: Fix no default display of ip4ip6 tunnels

Stephen,

>it is possible to see all with
>	ip -6 tunnel show mode all

I guess you meant "mode any" instead of "mode all". And yes, you are right - "mode any" does display all tunnels.

However the equivalent INET4 command - "ip tunnel show" displays all tunnels (gre/ipip/sit) irrespective of mode and from a end user point of view he would probably expect the same behaviour with the INET6 tunnels without having to specify "mode any"

If you agree, I'll submit a replacement patch for my earlier one which does the same thing.

Regards,
Srivats


Conexant E-mail Firewall (Conexant.Com) made the following annotations
---------------------------------------------------------------------
********************** Legal Disclaimer **************************** 

"This email may contain confidential and privileged material for the sole use of the intended recipient. Any unauthorized review, use or distribution by others is strictly prohibited. If you have received the message in error, please advise the sender by reply email and delete the message. Thank you." 

********************************************************************** 

---------------------------------------------------------------------

