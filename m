From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH/RFC] net: Don't save mid batch datagram processing error
 for next recvmmsg call
Date: Tue, 22 Jul 2014 08:33:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1727AECC@AcuExch.aculab.com>
References: <20140721193042.GA20303@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Linux Networking Development Mailing List
	<netdev@vger.kernel.org>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Chris Friesen <chris.friesen@windriver.com>,
	Elie De Brauwer <eliedebrauwer@gmail.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	=?iso-8859-2?Q?Ond=F8ej_B=EDlka?= <neleai@seznam.cz>,
	Paul Moore <paul@paul-moore.com>,
	=?iso-8859-2?Q?R=E9mi_Denis-Courmont?= <remi@remlab.net>,
	Steven Whitehouse <steve@chygwyn.com>
To: 'Arnaldo Carvalho de Melo' <acme@kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37060 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752737AbaGVIeq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 04:34:46 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00488-04 for <netdev@vger.kernel.org>;
 Tue, 22 Jul 2014 09:34:37 +0100 (BST)
In-Reply-To: <20140721193042.GA20303@kernel.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo 
> 	I think this addresses the problems reported by David Laight and
> others, where errors saved on a per socket area could be delivered to a
> different thread, so I just followed David Laight's suggestion and
> stopped saving it, we'll return it only if it happens for the first
> datagram, else we return less entries than asked for.
> 
> 	Steven, IIRC you was the one that suggested using this
> mechanism, no? Do you have anything against this move?

+	return datagrams ?: err;

Inline patches, don't attach them.

Don't use non-C constructs.

	David
