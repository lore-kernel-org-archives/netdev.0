From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 1/2] ipv4: L3 hash-based multipath
Date: Wed, 23 Sep 2015 14:55:21 -0700 (PDT)
Message-ID: <20150923.145521.609102724670024669.davem@davemloft.net>
References: <1443037777-25390-1-git-send-email-pch@ordbogen.com>
	<1443037777-25390-2-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: pch@ordbogen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500AbbIWVzW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 17:55:22 -0400
In-Reply-To: <1443037777-25390-2-git-send-email-pch@ordbogen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Peter N=F8rlund <pch@ordbogen.com>
Date: Wed, 23 Sep 2015 21:49:36 +0200

> +static inline int fib_multipath_hash(__be32 saddr, __be32 daddr)
> +{
> +	return jhash_2words(saddr, daddr, fib_multipath_secret) >> 1;
> +}

Like Tom I'm curious why you do this shift here?
