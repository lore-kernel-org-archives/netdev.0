From: "Rune Torgersen" <runet@innovsys.com>
Subject: RE: Ethernet weirdness on 82xx
Date: Tue, 4 Sep 2007 09:06:07 -0500
Message-ID: <DCEAAC0833DD314AB0B58112AD99B93B0353A81A@ismail.innsys.innovsys.com>
References: <DCEAAC0833DD314AB0B58112AD99B93B0353A6AB@ismail.innsys.innovsys.com> <20070902110957.M44221@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Denys" <denys@visp.net.lb>, <linuxppc-embedded@ozlabs.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.innovsys.com ([66.115.232.196]:43034 "EHLO
	mail.innovsys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753714AbXIDOGE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 10:06:04 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070902110957.M44221@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Denys [mailto:denys@visp.net.lb] 
> Sent: Sunday, September 02, 2007 6:12 AM
> To: Rune Torgersen; linuxppc-embedded@ozlabs.org; 
> netdev@vger.kernel.org
> Subject: Re: Ethernet weirdness on 82xx
> 
> Thats normal.
> Check arp_filter sysctl :
> arp_filter - BOOLEAN

Thank you, that was it.

Did the following, and now I don't get the double resond anymore

#only respond to arps on the correct port
echo 1 > /proc/sys/net/ipv4/conf/all/arp_announce
echo 2 > /proc/sys/net/ipv4/conf/all/arp_ignore
