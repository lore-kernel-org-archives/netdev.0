From: "Ananda Raju" <Ananda.Raju@neterion.com>
Subject: RE: [1/4] [IPV6]: Remove redundant length check on input
Date: Fri, 30 Jun 2006 20:08:25 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7793A4D1@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	<herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:56036 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S933054AbWGAAIm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 20:08:42 -0400
Received: from owa.neterion.com (unknown [72.1.205.142])
	by barracuda.mail.s2io.com (Spam Firewall) with ESMTP id AB4652014A94
	for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 20:08:41 -0400 (EDT)
Content-class: urn:content-classes:message
To: "Michael Chan" <mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sure, we will do that. 

-----Original Message-----
From: Michael Chan [mailto:mchan@broadcom.com] 
Sent: Friday, June 30, 2006 5:08 PM
To: Ananda Raju
Cc: David Miller; herbert@gondor.apana.org.au; netdev@vger.kernel.org
Subject: RE: [1/4] [IPV6]: Remove redundant length check on input

On Fri, 2006-06-30 at 19:55 -0400, Ananda Raju wrote:
> True, I am referring to "ethtool -K ethX tso off"
> ethtool_op_set_tso() won't clear NETIF_F_TSO6 for ethtool -K ethX tso
> off
> 
Instead of using ethtool_op_set_tso() in your ethtool_ops structure, you
can use a private function to set or clear any new bits such as
NETIF_F_TSO6 or NETIF_F_TSO_ECN.


