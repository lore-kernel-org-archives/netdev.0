From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] net: Remove protocol from struct dst_ops
Date: Mon, 09 Mar 2015 16:06:49 -0400 (EDT)
Message-ID: <20150309.160649.1179626615167544773.davem@redhat.com>
References: <87zj7m11iq.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50647 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751501AbbCIUGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 16:06:50 -0400
In-Reply-To: <87zj7m11iq.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 09 Mar 2015 13:14:37 -0500

> After my change to neigh_hh_init to obtain the protocol from the
> neigh_table there are no more users of protocol in struct dst_ops.
> Remove the protocol field from dst_ops and all of it's initializers.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Looks great, applied, thanks Eric.
