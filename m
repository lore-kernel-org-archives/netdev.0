From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] inetpeer not namespace ready
Date: Fri, 10 Jun 2011 00:07:26 -0700 (PDT)
Message-ID: <20110610.000726.1162222892459021164.davem@davemloft.net>
References: <1307681090.3210.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab1FJHHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 03:07:32 -0400
In-Reply-To: <1307681090.3210.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Jun 2011 06:44:50 +0200

> Shouldnt we make inetpeer cache namespace aware ?
> 
> Same destination IP can be used differently in two different namespaces.

Maybe.  Although it would be a shame not to be able to share metrics
between namespaces.
