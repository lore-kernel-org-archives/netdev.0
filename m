From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] net: sync some IP headers with glibc
Date: Wed, 04 Sep 2013 13:13:51 -0400 (EDT)
Message-ID: <20130904.131351.1326721513428082697.davem@davemloft.net>
References: <1376558891-26221-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tmb@mageia.org, libc-alpha@sourceware.org,
	yoshfuji@linux-ipv6.org, carlos@redhat.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40683 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286Ab3IDRNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 13:13:55 -0400
In-Reply-To: <1376558891-26221-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu, 15 Aug 2013 17:28:10 +0800

> Solution:
> =========
> 
> - Synchronize linux's `include/uapi/linux/in6.h' 
>   with glibc's `inet/netinet/in.h'.
> - Synchronize glibc's `inet/netinet/in.h with linux's
>   `include/uapi/linux/in6.h'.
> - Allow including the headers in either other.
> - First header included defines the structures and macros.

Applied, thanks for being so patient.  I want to spend the past few
weeks making sure this is the right way to handle all of this and
now I am confident that it is.

Thanks!
