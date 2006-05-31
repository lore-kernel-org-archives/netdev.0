From: David Miller <davem@davemloft.net>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Wed, 31 May 2006 00:10:27 -0700 (PDT)
Message-ID: <20060531.001027.60486156.davem@davemloft.net>
References: <20060531042908.10463.qmail@web51410.mail.yahoo.com>
	<20060530235525.A30563@openss7.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: draghuram@rocketmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15503
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S964854AbWEaHKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 03:10:07 -0400
To: bidulock@openss7.org
In-Reply-To: <20060530235525.A30563@openss7.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Date: Tue, 30 May 2006 23:55:26 -0600

> For example, it goes to great pains to permute upper order bits in
> the local address, which for most connections will be a constant
> value.

Consider an apache server hosting thousands of virtual
hosts.  The local address will be different for every
such host.

Please drop linux-kernel in any future replies, this
discussion belongs on netdev not linux-kernel.  Thanks.
