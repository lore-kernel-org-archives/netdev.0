From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/8] tipc: decrease connection flow control
 window
Date: Wed, 14 May 2014 04:50:33 -0700
Message-ID: <1400068233.7973.80.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
	 <1400060355-26308-2-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:64618 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754950AbaENLuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 07:50:39 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so1598518pbb.36
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 04:50:38 -0700 (PDT)
In-Reply-To: <1400060355-26308-2-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 05:39 -0400, Jon Maloy wrote:
> Memory overhead when allocating big buffers for data transfer may
> be quite significant. E.g., truesize of a 64 KB buffer turns out
> to be 132 KB, 2 x the requested size.

It might be time to use a different strategy for skb allocations then ?

Is this because TIPC does not support SG ?
