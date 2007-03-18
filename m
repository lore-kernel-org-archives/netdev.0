From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try
 #2]
Date: Sun, 18 Mar 2007 14:23:15 +0000
Message-ID: <20070318142315.6f881ec8@lxorguk.ukuu.org.uk>
References: <20070316153408.3a9a244a@lxorguk.ukuu.org.uk>
	<20070316151305.04cbc352@lxorguk.ukuu.org.uk>
	<20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
	<25571.1174054993@redhat.com>
	<26525.1174058071@redhat.com>
	<20070316171141.7a4de504@lxorguk.ukuu.org.uk>
	<076F1B35-BE08-41B4-8294-581EDAFF4ACC@mac.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Howells <dhowells@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: Kyle Moffett <mrmacman_g4@mac.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:47198 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753782AbXCSKAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 06:00:40 -0400
In-Reply-To: <076F1B35-BE08-41B4-8294-581EDAFF4ACC@mac.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> IMHO the problem with classifying RxRPC as a "reliable datagram"  
> socket is that even an atomic unidirectional communication isn't a  
> single datagram, it's at least 3; there is shared connection state  

Thats fine. Any *reliable* protocol sends more than one packet per
message you send. RDM is for reliable messages

> independent and possibly simultaneous RxRPC calls.  From the digging  
> around that I did in the kernel socket code a while ago I don't see a  
> cleaner way of implementing it than a new SOCK_RXRPC.

I disagree entirely. I've still seen no evidence you need a new type for
this. What does AIX do  out of interest ?
