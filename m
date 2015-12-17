From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 0/4] Support administratively closing application
 sockets
Date: Wed, 16 Dec 2015 19:15:59 -0500 (EST)
Message-ID: <20151216.191559.1301813441203295326.davem@davemloft.net>
References: <1450281013.8474.73.camel@edumazet-glaptop2.roam.corp.google.com>
	<5671C1A3.30207@mojatatu.com>
	<1450308935.8474.103.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, stephen@networkplumber.org, lorenzo@google.com,
	netdev@vger.kernel.org, hannes@stressinduktion.org, ek@google.com,
	tom@herbertland.com, zenczykowski@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbbLQAQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 19:16:01 -0500
In-Reply-To: <1450308935.8474.103.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Dec 2015 15:35:35 -0800

> socket can be shared by fd passing to multiple users.
> 
> Who really owns it ?

Oh yes the old fd permission discussion...

Probably need to use the openner's permissions.
