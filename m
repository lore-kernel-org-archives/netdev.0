From: "Ananda Raju" <Ananda.Raju@neterion.com>
Subject: RE: [1/4] [IPV6]: Remove redundant length check on input
Date: Fri, 30 Jun 2006 19:55:18 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7793A4CB@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	<herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:37604 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1751726AbWF3Xzd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 19:55:33 -0400
Received: from owa.neterion.com (unknown [72.1.205.142])
	by barracuda.mail.s2io.com (Spam Firewall) with ESMTP id 4DEE92014A94
	for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 19:55:32 -0400 (EDT)
Content-class: urn:content-classes:message
To: "Michael Chan" <mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

True, I am referring to "ethtool -K ethX tso off"
ethtool_op_set_tso() won't clear NETIF_F_TSO6 for ethtool -K ethX tso
off

Ananda 
-----Original Message-----
From: Michael Chan [mailto:mchan@broadcom.com] 
Sent: Friday, June 30, 2006 4:53 PM
To: Ananda Raju
Cc: David Miller; herbert@gondor.apana.org.au; netdev@vger.kernel.org
Subject: RE: [1/4] [IPV6]: Remove redundant length check on input

On Fri, 2006-06-30 at 19:44 -0400, Ananda Raju wrote:
> Hi, 
> 
> I tested the patch, and TSO over ipv6 is working fine. But TSO disable
> not working for IPv6. 
> 
You need to clear NETIF_F_TSO6 in dev->features to disable ipv6 TSO.


