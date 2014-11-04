From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: Do not reuse sockets for a different
 address family
Date: Tue, 04 Nov 2014 11:32:03 -0500 (EST)
Message-ID: <20141104.113203.432907272611801931.davem@davemloft.net>
References: <b2c5c4c68f0ae715802b4b4fd35fd1031c65aac0.1415108561.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbaKDQcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 11:32:06 -0500
In-Reply-To: <b2c5c4c68f0ae715802b4b4fd35fd1031c65aac0.1415108561.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Tue,  4 Nov 2014 11:46:49 -0200

>  	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
> -		if (inet_sk(vs->sock->sk)->inet_sport == port)
> +		if ((inet_sk(vs->sock->sk)->inet_sport == port) &&
> +			(inet_sk(vs->sock->sk)->sk.sk_family == family))

This is not indented properly.

For a multi-line conditional, the second and subsequent lines
should start precisely at the first column after the openning
parenthesis on the first line.

You must use the appropriate number of TAB and SPACE characters
necessary to achieve this.  If you are only using TAB characters, you
are most likely doing it wrong.

Please fix this up and resubmit, thanks.
