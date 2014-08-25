From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Sun, 24 Aug 2014 23:10:55 -0700 (PDT)
Message-ID: <20140824.231055.667855333558025304.davem@davemloft.net>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54579 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753661AbaHYGK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 02:10:56 -0400
In-Reply-To: <20140823.132811.751469424156827125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In the interest of having something to readily build upon, I pushed
my changes into net-next with the bug fixed that Alexander Duyck
pointed out.

Don't panic, if this turns out to be the wrong interface we'll adjust
it or just completely revert my changes.
