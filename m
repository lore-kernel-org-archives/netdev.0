From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during
 softnet overflow
Date: Tue, 23 Apr 2013 18:34:36 -0400 (EDT)
Message-ID: <20130423.183436.1282688375322312690.davem@davemloft.net>
References: <20130423142333.15479dfa@nehalam.linuxnetplumber.net>
	<1366753063.8964.14.camel@edumazet-glaptop>
	<20130423145222.5b696d0c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, willemb@google.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756324Ab3DWWei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 18:34:38 -0400
In-Reply-To: <20130423145222.5b696d0c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 23 Apr 2013 14:52:22 -0700

> I just don't want to get tied down to one hard coded policy.  User
> seem have different ideas about what constitutes a flow and what
> policy for drop should be.  Existing ingress qdisc is inflexible and
> ifb is a pain to setup and adds another queue transistion.

There is no hard coded policy.

User defines his policy by what cpu he executes his socket reads and
writes upon, and RFS reacts in kind.
