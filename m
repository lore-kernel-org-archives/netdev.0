From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too
 long
Date: Wed, 20 Mar 2013 12:07:05 -0400 (EDT)
Message-ID: <20130320.120705.58997943737455552.davem@davemloft.net>
References: <1363693648-10015-1-git-send-email-yamato@redhat.com>
	<1363693648-10015-2-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yamato@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755601Ab3CTQHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 12:07:07 -0400
In-Reply-To: <1363693648-10015-2-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masatake YAMATO <yamato@redhat.com>
Date: Tue, 19 Mar 2013 20:47:27 +0900

> Trigger BUG_ON if a group name is longer than GENL_NAMSIZ.
> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>

Applied, thanks.

Although I'm disappointed that the compiler doesn't say anything about
this in the assignment.

We're assigning "char[16] = STRING" and it doesn't say anything if the
final NULL char doesn't fit into the array.
