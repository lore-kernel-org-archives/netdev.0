From: David Miller <davem@davemloft.net>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 17:44:31 -0400 (EDT)
Message-ID: <20110517.174431.1004332995189918916.davem@davemloft.net>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40893 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932360Ab1EQVoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:44:34 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4HLiWTq022910
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 14:44:33 -0700
In-Reply-To: <20110517.143342.1566027350038182221.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Guys we can't time out fragments if we are not the final
destination.

Due to assymetric routing, the fragment pieces we don't
see might reach the final destiantion not through us.

So we have to pass them onwards, we can't just drop them.
