From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] TCP: Use 32768-65535 outgoing port range by default
Date: Tue, 03 Apr 2012 02:28:37 -0400 (EDT)
Message-ID: <20120403.022837.1830755903242379322.davem@davemloft.net>
References: <20120403095018.rm7gil9xz0gsgccs@webmail.int.intellilink.co.jp>
	<20120403.005027.988304181797945160.davem@davemloft.net>
	<20120403141827.sakagdugg04os8w8@webmail.int.intellilink.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: fernando@intellilink.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58774 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215Ab2DCG2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 02:28:51 -0400
In-Reply-To: <20120403141827.sakagdugg04os8w8@webmail.int.intellilink.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fernando@intellilink.co.jp
Date: Tue,  3 Apr 2012 14:18:27 +0900

> The thing is that certain non-linux hosts already use a superset of
> the 61000-65095 range and 61000 looks like a magic number to most
> users.

Who cares what other systems usage, it's only an issue about local
port allocations and locally performed masquerading.

> Do you want me to document where 61000 comes from instead?

I think the current documentation on this is adequate.
