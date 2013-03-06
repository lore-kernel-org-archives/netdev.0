From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: ipv6: bind() use stronger condition for
 bind_conflict
Date: Tue, 05 Mar 2013 23:54:44 -0500 (EST)
Message-ID: <20130305.235444.1139109745031015500.davem@davemloft.net>
References: <1362507061-22475-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595Ab3CFEyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 23:54:45 -0500
In-Reply-To: <1362507061-22475-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Tue,  5 Mar 2013 15:11:01 -0300

> We must try harder to get unique (addr, port) pairs when
> doing port autoselection for sockets with SO_REUSEADDR
> option set.
> 
> This is a continuation of commit aacd9289af8b82f5fb01bcdd53d0e3406d1333c7
> for IPv6.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

I think this is 'net' material, therefore that's will I will apply
this, thanks Flavio.
