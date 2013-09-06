From: David Miller <davem@davemloft.net>
Subject: Re: [RFC Patch net-next] ipv6: do not allow ipv6 module to be
 removed
Date: Thu, 05 Sep 2013 22:58:38 -0400 (EDT)
Message-ID: <20130905.225838.457359862533804955.davem@davemloft.net>
References: <1378285970-21404-1-git-send-email-amwang@redhat.com>
	<20130905.140604.2263717213507575570.davem@davemloft.net>
	<1378435971.969.6.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732Ab3IFC6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 22:58:40 -0400
In-Reply-To: <1378435971.969.6.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri, 06 Sep 2013 10:52:51 +0800

> On Thu, 2013-09-05 at 14:06 -0400, David Miller wrote:
>> And this patch has a lot of problems, you aren't removing all of
>> the functions which will be completely unused.
> 
> They are still used in the cleanup path of inet6_init() as well, can't
> be removed completely.

Good point.
