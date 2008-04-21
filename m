From: David Miller <davem@davemloft.net>
Subject: Re: tx-checksumming for an Intel Corporation 82540EP Gigabit
 Ethernet Controller (Mobile)
Date: Sun, 20 Apr 2008 21:24:51 -0700 (PDT)
Message-ID: <20080420.212451.10825959.davem@davemloft.net>
References: <47EB8C5C.7060007@isomerica.net>
	<E1Jnn9e-0001tP-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dpn@isomerica.net, toralf.foerster@gmx.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50681
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750792AbYDUEYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 00:24:49 -0400
In-Reply-To: <E1Jnn9e-0001tP-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 21 Apr 2008 11:57:22 +0800

> Daniel Noe <dpn@isomerica.net> wrote:
> >
> > 2) Tell Wireshark not to verify the checksums.  See 
> > http://wiki.wireshark.org/TCP_Checksum_Verification.  This works if you 
> > don't really care about the checksums and are looking at other things. 
> > If you suspect incorrect checksums, you can always turn off checksum 
> > offloading manually.
> 
> Better yet fix Wireshark to use the info that the kernel supplies
> and ignore checksums only on those packets generated locally for
> hardware offload.

True.

But every time we say this they keep coming back at us that they can't
change the tcpdump raw dump file format that's been used for
centuries, and naturally it was designed without any extensibility in
mind so there's nowhere to store the checksum indication.
