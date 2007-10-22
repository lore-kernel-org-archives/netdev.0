From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH 0/3][XFRM]: Support packet processing error
	statistics.
Date: Mon, 22 Oct 2007 08:28:11 -0400
Message-ID: <1193056091.4422.33.camel@localhost>
References: <20071017.213523.58458049.davem@davemloft.net>
	 <11930334662094-git-send-email-nakam@linux-ipv6.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:44510 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbXJVM2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 08:28:16 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1336613wxd
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 05:28:15 -0700 (PDT)
In-Reply-To: <11930334662094-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-22-10 at 15:11 +0900, Masahide NAKAMURA wrote:
> This patch introduces statistics about transformation error (or almost error)
> factor at packet processing for developer.
> It is not a SNMP/MIB specification from IPsec/MIPv6 but a counter
> designed from current transformation source code.
> 
> Comment please.

very nice - these stats make IPSEC a lot more usable (I will go look and
see if theres anything that i have used for debug before that you dont
have and send you mail). Two comments:

1) Since these are not MIB stats, it sounds like a good idea not to use
_MIB_ extender in the naming. Maybe something like _NOTMIB_ ;-> or
totaly leave it out. One other approach is to push these to be a MIB at
IETF since they are sensible to have.

2) Why /proc? Are you going to make these available also via netlink? 

cheers,
jamal

