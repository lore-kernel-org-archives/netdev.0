From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 0/4] Support administratively closing application
 sockets
Date: Wed, 16 Dec 2015 18:24:13 -0500 (EST)
Message-ID: <20151216.182413.1561030855644800839.davem@davemloft.net>
References: <20151216074334.593a1ad6@xeon-e3>
	<1450281013.8474.73.camel@edumazet-glaptop2.roam.corp.google.com>
	<5671C1A3.30207@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, stephen@networkplumber.org,
	lorenzo@google.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbbLPXYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 18:24:15 -0500
In-Reply-To: <5671C1A3.30207@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Wed, 16 Dec 2015 14:55:15 -0500

> The question i had was the opposite when i saw this: why are
> regular users allowed to read admin (and any other users) details?;->
> On this specific feature: why, as a regular user, I cant close
> connections attributed to me (and have to use CAP_NET_ADMIN)?

There is nothing provided via socket diag that can't be seen
also via /proc/net/tcp et al.
