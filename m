From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: RFC - VXLAN port range facility
Date: Sat, 1 Jun 2013 09:28:47 -0400
Message-ID: <OF899AA605.66A68C35-ON85257B7D.0049BE0D-85257B7D.004A0C16@us.ibm.com>
References: <OF673FF136.10B22631-ON85257B7B.00436301-85257B7B.0045AAB7@us.ibm.com>	<20130530094141.7c125947@nehalam.linuxnetplumber.net>
	<OFD5BD589B.1842E46B-ON85257B7B.00610E03-85257B7B.0062F480@us.ibm.com>	<20130531091338.12fc7df5@nehalam.linuxnetplumber.net>
	<OF19ABC0E6.77100D83-ON85257B7C.005AFB01-85257B7C.005E33DC@us.ibm.com>	<20130531102233.13e51cff@nehalam.linuxnetplumber.net>
	<OF5DED87DF.8E295C17-ON85257B7C.0061E7B1-85257B7C.0064B099@us.ibm.com> <20130531184310.59c777fb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:46960 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756873Ab3FAN2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 09:28:54 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Sat, 1 Jun 2013 07:28:53 -0600
In-Reply-To: <20130531184310.59c777fb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> wrote on 05/31/2013 
09:43:10 PM:

> 
> I am wondering if this is just a theoretical problem, or does it occur
> in real life. My simple tests are not causing ICMP to be delivered to
> UDP application (over the VXLAN) but it maybe because of the compare 
scoring
> in ICMP, or because of use of multicast versus unicast destinations.
> 

ICMP won't sent errors triggered by multicasts.

                                                        +-DLS
