From: Roland Dreier <rdreier@cisco.com>
Subject: Re: depending on IPv6 symbols
Date: Tue, 06 Feb 2007 16:07:34 -0800
Message-ID: <ada8xfarfsp.fsf@cisco.com>
References: <adaodo6sy9o.fsf_-_@cisco.com>
	<20070206.144939.118629871.davem@davemloft.net>
	<adad54msxrt.fsf@cisco.com>
	<20070206.153302.41699956.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kazunori@miyazawa.org, miika@iki.fi, Diego.Beltrami@hiit.fi,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, mst@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:21266 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030258AbXBGAHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 19:07:49 -0500
In-Reply-To: <20070206.153302.41699956.davem@davemloft.net> (David Miller's message of "Tue, 06 Feb 2007 15:33:02 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    David> Sure, although I'm surprised nobody noticed that build
    David> failure before :-)

OK, coming up.  (It's not a build failure though, it's wrong code: if
CONFIG_IPV6=m then the code inside "#ifdef CONFIG_IPV6" in ip_gre.c
just doesn't get built, even though it should)

 - R.
