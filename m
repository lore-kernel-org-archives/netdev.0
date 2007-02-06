From: Roland Dreier <rdreier@cisco.com>
Subject: Re: depending on IPv6 symbols
Date: Tue, 06 Feb 2007 14:53:58 -0800
Message-ID: <adad54msxrt.fsf@cisco.com>
References: <20061229144702.11ff0478.kazunori@miyazawa.org>
	<20070206.142407.48395902.davem@davemloft.net>
	<adaodo6sy9o.fsf_-_@cisco.com>
	<20070206.144939.118629871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kazunori@miyazawa.org, miika@iki.fi, Diego.Beltrami@hiit.fi,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, mst@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:8790 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030232AbXBFWyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 17:54:04 -0500
In-Reply-To: <20070206.144939.118629871.davem@davemloft.net> (David Miller's message of "Tue, 06 Feb 2007 14:49:39 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > config FOO
 > 	depends on (IPV6 || IPV6=n)

OK, I'll add the same hack for INFINIBAND_IPOIB too.  I doubt there's
anyone that really cares about IPoIB built-in with modular IPv6.

Would you like a patch to do the same thing for INET_IPGRE (and fix
the #ifdefs in ip_gre.c)?

 - R.
