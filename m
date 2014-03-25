From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 7/9] net: isdn: use sk_unattached_filter api
Date: Tue, 25 Mar 2014 19:08:06 -0400 (EDT)
Message-ID: <20140325.190806.874901064522999616.davem@davemloft.net>
References: <1395749457-16178-1-git-send-email-dborkman@redhat.com>
	<1395749457-16178-8-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org, isdn@linux-pingi.de,
	isdn4linux@listserv.isdn4linux.de
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbaCYXII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 19:08:08 -0400
In-Reply-To: <1395749457-16178-8-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 25 Mar 2014 13:10:55 +0100

> Similarly as in ppp, we need to migrate the ISDN/PPP code to make use
> of the sk_unattached_filter api in order to decouple having direct
> filter structure access. By using sk_unattached_filter_{create,destroy},
> we can allow for the possibility to jit compile filters for faster
> filter verdicts as well.
> 
> Joint work with Alexei Starovoitov.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Hehe, this finally got squeezed out of the mail server.
