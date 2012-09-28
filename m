From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] tcp: introduce tcp_tw_interval to
 specifiy the time of TIME-WAIT
Date: Fri, 28 Sep 2012 02:44:16 -0400 (EDT)
Message-ID: <20120928.024416.1606551804314602583.davem@davemloft.net>
References: <1348735261-29225-1-git-send-email-amwang@redhat.com>
	<20120927.130529.620560818048014548.davem@davemloft.net>
	<1348814399.7264.44.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, kaber@trash.net,
	edumazet@google.com, nhorman@tuxdriver.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950Ab2I1GoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 02:44:17 -0400
In-Reply-To: <1348814399.7264.44.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri, 28 Sep 2012 14:39:59 +0800

> On Thu, 2012-09-27 at 13:05 -0400, David Miller wrote:
>> 
>> Without appropriate confirmation that an early time-wait reuse is
>> valid, decreasing this interval can only be dangerous.
> 
> Yeah, would a proper documentation cure this? Something like we did for
> other tuning:
> 
> "It should not be changed without advice/request of technical experts."

No, we're not adding this facility.
