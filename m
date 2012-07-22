From: "Neil Horman <nhorman@tuxdriver.com>" <nhorman@tuxdriver.com>
Subject: Re: [PATCH v6] sctp: Implement quick failover draft from tsvwg
Date: Sun, 22 Jul 2012 15:18:15 -0400
Message-ID: <da1c7d5d-5faf-495f-af02-5b56b13d7f98@email.android.com>
References: <1342203998-24037-1-git-send-email-nhorman@tuxdriver.com> <1342893367-981-1-git-send-email-nhorman@tuxdriver.com> <2e6ee3f1-ea4f-4c13-b27b-1f2291fdb0c0@email.android.com> <20120722.121409.377271257112948379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, sri@us.ibm.com, linux-sctp@vger.kernel.org,
	joe@perches.com
To: David Miller <davem@davemloft.net>, vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40426 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab2GVTSY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 15:18:24 -0400
In-Reply-To: <20120722.121409.377271257112948379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks all!

David Miller <davem@davemloft.net> wrote:

>From: Vlad Yasevich <vyasevich@gmail.com>
>Date: Sun, 22 Jul 2012 14:18:12 -0400
>
>> Neil Horman <nhorman@tuxdriver.com> wrote:
>> 
>>>I've seen several attempts recently made to do quick failover of sctp
>>>transports
>>>by reducing various retransmit timers and counters.  While its
>possible
>>>to
>>>implement a faster failover on multihomed sctp associations, its not
>>>particularly robust, in that it can lead to unneeded retransmits, as
>>>well as
>>>false connection failures due to intermittent latency on a network.
>>>
>>>Instead, lets implement the new ietf quick failover draft found here:
>>>http://tools.ietf.org/html/draft-nishida-tsvwg-sctp-failover-05
>>>
>>>This will let the sctp stack identify transports that have had a
>small
>>>number of
>>>errors, and avoid using them quickly until their reliability can be
>>>re-established.  I've tested this out on two virt guests connected
>via
>>>multiple
>>>isolated virt networks and believe its in compliance with the above
>>>draft and
>>>works well.
>>>
>>>Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> ...
>> Acked-by: Vlad Yasevich <vyasevich@gmail.com>
>
>Applied, thanks everyone.

-- 
Sent from my Android phone with K-9 Mail. Please excuse my brevity.
