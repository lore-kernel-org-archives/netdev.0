From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] route: fix ICMP redirect validation
Date: Mon, 24 Oct 2011 02:56:47 -0400 (EDT)
Message-ID: <20111024.025647.1195164389515992138.davem@davemloft.net>
References: <1319215448-6777-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44373 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025Ab1JXG4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 02:56:49 -0400
In-Reply-To: <1319215448-6777-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Fri, 21 Oct 2011 14:44:08 -0200

> The commit f39925dbde7788cfb96419c0f092b086aa325c0f
> (ipv4: Cache learned redirect information in inetpeer.)
> removed some ICMP packet validations which are required by
> RFC 1122, section 3.2.2.2:
> ...
>   A Redirect message SHOULD be silently discarded if the new
>   gateway address it specifies is not on the same connected
>   (sub-) net through which the Redirect arrived [INTRO:2,
>   Appendix A], or if the source of the Redirect is not the
>   current first-hop gateway for the specified destination (see
>   Section 3.3.1).
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Applied, thanks.
