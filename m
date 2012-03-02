From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2012-03-01
Date: Thu, 01 Mar 2012 22:26:04 -0500 (EST)
Message-ID: <20120301.222604.1508242694024394849.davem@davemloft.net>
References: <20120302025554.GA13493@joana>
	<20120301.221643.881299898523907213.davem@davemloft.net>
	<20120301.222316.1877216960521396397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johan.hedberg@gmail.com, linville@tuxdriver.com,
	netdev@vger.kernel.org
To: gustavo@padovan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756503Ab2CBD1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 22:27:10 -0500
In-Reply-To: <20120301.222316.1877216960521396397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 01 Mar 2012 22:23:16 -0500 (EST)

> From: David Miller <davem@davemloft.net>
> Date: Thu, 01 Mar 2012 22:16:43 -0500 (EST)
> 
>> This was only three commits into your tree, therefore I'm not very
>> optimistic to be honest with you.
> 
> In the very next commit, 3175405b906a85ed2bad21e09c444266e4a05a8e we end
> up with:

And then 2 commits later in ff9ef5787046c3fd20cf9f7ca1cd70260c1eedb9:

+	if (hdev->discovery.state != DISCOVERY_STOPPED) {
+		err = cmd_status(sk, index, MGMT_OP_START_DISCOVERY,
+						MGMT_STATUS_BUSY);
+		goto failed;
+	}

it must be isntead:

		err = cmd_status(sk, index, MGMT_OP_START_DISCOVERY,
				 MGMT_STATUS_BUSY);

And that's pretty much as far as I'm willing to go.

You know what really pisses me off?  This is the one issue I made a huge
stink about last week, arguments to function calls and prototypes lining
up properl.  And it's in ever 2nd or 3rd commit in this pull request.

This means you really didn't check or you really don't care.

Come back when you've audited this whole thing properly and honestly.
