From: "Naveen B N (nbn)" <nbn@cisco.com>
Subject: RE: CPU usage for IPSec in Linux 2.6.38
Date: Tue, 10 Jan 2012 20:23:51 +0530
Message-ID: <A2354B6A9F807641B21EEABD666ECEEA02596D98@XMB-BGL-416.cisco.com>
References: <B97B134FACB2024DB45F524AB0A7B7F20545EA24@XMB-BGL-419.cisco.com><20203.19901.967544.547378@fireball.kivinen.iki.fi><B2C779B5E2D74D1792EB988E1B59B42B@trustworks.com> <A2354B6A9F807641B21EEABD666ECEEA02596D7C@XMB-BGL-416.cisco.com> <09787EF419216C41A903FD14EE5506DD030F1A4FDA@AUSX7MCPC103.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-1.cisco.com ([72.163.197.25]:32146 "EHLO
	bgl-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756379Ab2AJPDz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 10:03:55 -0500
Received: from xbh-bgl-411.cisco.com (xbh-bgl-411.cisco.com [72.163.129.201])
	by bgl-core-2.cisco.com (8.14.3/8.14.3) with ESMTP id q0AErqwZ006945
	for <netdev@vger.kernel.org>; Tue, 10 Jan 2012 14:53:52 GMT
Content-class: urn:content-classes:message
In-Reply-To: <09787EF419216C41A903FD14EE5506DD030F1A4FDA@AUSX7MCPC103.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
I am using linux 2.6.36 kernel and trying to add 6000 Ikev2/ipsec
tunnels at 20 Ikev2 messages per second , I am using netlink socket
which is set to NON_BLOCKING and i am sending XFRM SPD added for every
successful AUTH message received.

But the problem is after the 4000 tunnels are established, CPU usage
goes to > 90%, which will likely cause dropping of few AUTH response
from responder.

NOTE:
But when I disabled adding SPD messaged via netlink sockets using xfrm
messages, I am able to complete 6000 ikev2 SA negotiation successfully.

So the problem i am seeing is when sending XFRM netlink message > 4000.

Any solutions are or analysis different then the above is appreciated.


Thanks and Regards
Naveen
_______________________________________________
IPsec mailing list
IPsec@ietf.org
https://www.ietf.org/mailman/listinfo/ipsec
