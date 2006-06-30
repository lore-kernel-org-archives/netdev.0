From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: [PATCH 2.6.17] support for TSO over IPv6
Date: Fri, 30 Jun 2006 16:46:56 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD778C6B07@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <jgarzik@pobox.com>,
	<shemminger@osdl.org>,
	"Ravinandan Arakali" <Ravinandan.Arakali@neterion.com>,
	<sivakumar.subramani@neterion.com>,
	"Sriram Rapuru" <Sriram.Rapuru@neterion.com>,
	"Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:3297 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S932227AbWF3UrM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 16:47:12 -0400
Received: from owa.neterion.com (unknown [72.1.205.142])
	by barracuda.mail.s2io.com (Spam Firewall) with ESMTP id 40DC32014A79
	for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 16:47:11 -0400 (EDT)
Content-class: urn:content-classes:message
To: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Ananda Raju" <Ananda.Raju@neterion.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Herbert Xu [mailto:herbert@gondor.apana.org.au] 
> Sent: Thursday, June 29, 2006 5:39 PM
> To: Ananda Raju
> Cc: netdev@vger.kernel.org; jgarzik@pobox.com; 
> shemminger@osdl.org; Leonid Grossman; Ravinandan Arakali; 
> sivakumar.subramani@neterion.com; Sriram Rapuru; Michael Chan
> Subject: Re: [PATCH 2.6.17] support for TSO over IPv6
> 
> BTW, does your card handle ECN correctly? If not then we 
> should change the new ECN bit to apply to both TCPv4 and TCPv6 since
> 
> 1) We now have a piece of hardware that handles TSO6 and it 
> doesn't do ECN.
> 2) It's quite likely that if the NIC can handle ECN in TCPv4 
> then it can do
>    it in TCPv6.

Hi Herbert,
For TSO, our current ASIC replicates the two bits (ECE and CWR) across
every datagram sent out. 
Are we saying that the correct behavior should be:

If ECE == 1, then set it to one for all datagrams.
If CWR == 1, then set it to one for the first datagram, and set it to
zero for the rest?

Thanks,
Leonid


> 
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au> 
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 

