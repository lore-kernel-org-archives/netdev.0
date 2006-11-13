From: David Miller <davem@davemloft.net>
Subject: Re: why do we mangle checksums for v6 ICMP?
Date: Sun, 12 Nov 2006 23:04:37 -0800 (PST)
Message-ID: <20061112.230437.55150543.davem@davemloft.net>
References: <45536622.90708@hp.com>
	<20061109.151402.15590179.davem@davemloft.net>
	<20061111130724.6eccdfd0.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, viro@ftp.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15517
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1754140AbWKMHEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 02:04:32 -0500
To: billfink@mindspring.com
In-Reply-To: <20061111130724.6eccdfd0.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bill Fink <billfink@mindspring.com>
Date: Sat, 11 Nov 2006 13:07:24 -0500

> On a raw IPv6 socket, shouldn't the IP checksum just be left
> unchanged, so you can test transmission of IPv6 packets with
> an invalid zero IP checksum.  Or is raw not fully raw?

The code path where we do the "0 --> -1" conversion only executes when
inet->hdrincl is false.
