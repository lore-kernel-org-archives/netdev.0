From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwtunnel: fix memory leak
Date: Tue, 18 Aug 2015 19:11:30 -0700 (PDT)
Message-ID: <20150818.191130.1171809794931472459.davem@davemloft.net>
References: <54251151b649756a3aa6f30c8fafe2357150f5ee.1439916029.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43482 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbbHSCLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 22:11:31 -0400
In-Reply-To: <54251151b649756a3aa6f30c8fafe2357150f5ee.1439916029.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue, 18 Aug 2015 18:41:13 +0200

> The built lwtunnel_state struct has to be freed after comparison.
> 
> Fixes: 571e722676fe3 ("ipv4: support for fib route lwtunnel encap attributes")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied.
