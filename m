From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]: Can not set the IPV6_PKTINFO option
Date: Mon, 16 Jul 2007 23:25:05 +0900 (JST)
Message-ID: <20070716.232505.120810403.yoshfuji@linux-ipv6.org>
References: <E1IAR9h-0007nr-00@gondolin.me.apana.org.au>
	<200707161514.06324@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48082 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761692AbXGPOYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 10:24:23 -0400
In-Reply-To: <200707161514.06324@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200707161514.06324@strip-the-willow> (at Mon, 16 Jul 2007 15:14:06 +0100), Gerrit Renker <gerrit@erg.abdn.ac.uk> says:

> |  That is, someone needs to send a patch to the upstream manpages
> |  maintainer and fix the documentation to actually describe what the
> |  code does.
> |  
> If it is simply replacing IPV6_PKTINFO with IPV6_RECVPKTINFO then I'd be happy to do this.
> Anything more complicated than that - it would be good to have some of the developers taking
> a look. 
> 
> Here is the text of the manpage (ipv6 in section 7):
> 
> IPV6_PKTINFO
>   Set delivery of the IPV6_PKTINFO control message on incoming datagrams.  
>   Only allowed for SOCK_DGRAM  or  SOCK_RAW sockets.  Argument is a pointer to a 
>   boolean value in an integer.

Description is outdated (RFC2292).
Current Linux basically follows RFC3542.

--yoshfuji
