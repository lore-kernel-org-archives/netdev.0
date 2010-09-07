From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/13] net/ipv4: Remove unnecessary casts of
 private_data
Date: Mon, 06 Sep 2010 18:47:49 -0700 (PDT)
Message-ID: <20100906.184749.214227378.davem@davemloft.net>
References: <cover.1283650107.git.joe@perches.com>
	<dd5d79c3aa9f2cffbca1a8d4a9163b0d6a9492a9.1283650107.git.joe@perches.com>
	<20100906.183036.68150190.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47533
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754463Ab0IGBrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:47:31 -0400
In-Reply-To: <20100906.183036.68150190.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 06 Sep 2010 18:30:36 -0700 (PDT)

> From: Joe Perches <joe@perches.com>
> Date: Sat,  4 Sep 2010 18:52:52 -0700
> 
>> Signed-off-by: Joe Perches <joe@perches.com>
> 
> Applied.

So Joe, did you even friggin' build test this?

raw_seq_private() expands to something which dereferences the pointer,
which you've now made void, which is illegal and breaks the build.

Reverted.

