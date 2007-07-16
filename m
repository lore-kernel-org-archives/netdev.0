From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH]: Can not set the IPV6_PKTINFO option
Date: Mon, 16 Jul 2007 15:14:06 +0100
Message-ID: <200707161514.06324@strip-the-willow>
References: <E1IAR9h-0007nr-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:64894 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932920AbXGPOQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 10:16:09 -0400
In-Reply-To: <E1IAR9h-0007nr-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

|  That is, someone needs to send a patch to the upstream manpages
|  maintainer and fix the documentation to actually describe what the
|  code does.
|  
If it is simply replacing IPV6_PKTINFO with IPV6_RECVPKTINFO then I'd be happy to do this.
Anything more complicated than that - it would be good to have some of the developers taking
a look. 

Here is the text of the manpage (ipv6 in section 7):

IPV6_PKTINFO
  Set delivery of the IPV6_PKTINFO control message on incoming datagrams.  
  Only allowed for SOCK_DGRAM  or  SOCK_RAW sockets.  Argument is a pointer to a 
  boolean value in an integer.

The v4 IP_PKTINFO works in the same way as the above description.


Gerrit
