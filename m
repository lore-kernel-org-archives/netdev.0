From: Casper.Dik@oracle.com
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for sockets in accept(3)
Date: Thu, 22 Oct 2015 08:51:20 +0200
Message-ID: <201510220651.t9M6pKs1018174@room101.nl.oracle.com>
References: <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk> <20151021.182955.1434243485706993231.davem@davemloft.net> <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23670 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754748AbbJVHHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 03:07:23 -0400
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t9M77MP4004413
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 07:07:22 GMT
Received: from room101.nl.oracle.com (room101.nl.oracle.com [10.161.249.34])
	by aserv0022.oracle.com (8.13.8/8.13.8) with ESMTP id t9M6sV68031255
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 07:07:21 GMT
In-Reply-To: <20151022044458.GP22011@ZenIV.linux.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Al Viro <viro@ZenIV.linux.org.uk>

>Except that in this case "correctness" is the matter of rather obscure and
>ill-documented areas in POSIX.  Don't get me wrong - this semantics isn't
>inherently bad, but it's nowhere near being an absolute requirement.

It would more fruitful to have such a discussion in one of the OpenGroup 
mailing lists; people gathered there have a lot of experience and it is 
also possible to fix the standard when it turns out that it indeed as 
vague as you claim it is (I don't quite agree with that)

Casper
