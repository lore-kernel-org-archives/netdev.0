From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1 net-2.6] s2io: enabling VLAN tag stripping at driver
 initialization
Date: Sat, 13 Sep 2008 16:26:25 -0400
Message-ID: <48CC21F1.8090607@garzik.org>
References: <48C01EDB.7020001@linux.vnet.ibm.com> <78C9135A3D2ECE4B8162EBDCE82CAD7704330496@nekter> <48C04AA6.1010808@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	santosh.rastapur@neterion.com, sivakumar.subramani@neterion.com,
	sreenivasa.honnur@neterion.com, Jay Vosburgh <fubar@us.ibm.com>,
	netdev <netdev@vger.kernel.org>, Lorandi <rafaello@br.ibm.com>
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42091 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259AbYIMU0h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 16:26:37 -0400
In-Reply-To: <48C04AA6.1010808@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Breno Leitao wrote:
> Actually s2io has a bug in VLAN support. VLAN doesn't work except if
> you'd opened the interface in promiscuous mode before.
> This happens because VLAN tag stripping is not correctly marked as
> enabled at device startup
> 
> Also, the vlan_strip_flag field was moved to the private network
> structure. 
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

applied


