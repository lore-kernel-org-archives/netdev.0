From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sctp: Add buffer utilization fields to
 /proc/net/sctp/assocs
Date: Fri, 12 Apr 2013 15:09:56 -0400 (EDT)
Message-ID: <20130412.150956.828923278890458461.davem@davemloft.net>
References: <1365709796.14620.43.camel@pro6455b.example.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, dborkman@redhat.com
To: dilip.daya@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab3DLTJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 15:09:58 -0400
In-Reply-To: <1365709796.14620.43.camel@pro6455b.example.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dilip Daya <dilip.daya@hp.com>
Date: Thu, 11 Apr 2013 15:49:56 -0400

> From: Dilip Daya <dilip.daya@hp.com>
> 
> sctp: Add buffer utilization fields to /proc/net/sctp/assocs
> 
> This patch adds the following fields to /proc/net/sctp/assocs output:
> 
> 	- sk->sk_wmem_alloc    (transmit queue bytes committed)
> 	- sk->sk_wmem_queued   (persistent queue size)
> 	- sk->sk_sndbuf        (size of send buffer in bytes)
> 	- sk->sk_rcvbuf        (size of receive buffer in bytes)

Please use smaller field names, perhaps "wmema wmemq sndbuf rcvbuf"

> Patch applies to v3.8.6 and v3.9-rc6.

This does not belong in the commit message proper, it belongs in the
ancillary information you provide after the "---" delimeter.

> v2: Not changing spacing between the fields.

Similarly this supplemental information belongs after "---"

> +		seq_printf(seq, "\t%8lu %5d %5d %4d %4d %4d %8d "
> +						"%8d %8d %8d %8d",

This is not indented properly, the second line should have the "
appearing at the first column after the openning parenthesis
of the seq_printf() call.

The goal is not to exclusively use TAB characters to indent the
line into outer space, the goal is to use the appropriate of
TAB, then space, characters as necessary to indent the code to
the correct column.
