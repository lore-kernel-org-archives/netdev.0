From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: allow for bigger reordering level
Date: Wed, 29 Oct 2014 12:27:49 -0700
Message-ID: <1414610869.631.94.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414471524.13259.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141029.150624.878155212768758630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wygivan@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:62990 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756101AbaJ2T1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 15:27:48 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so3764240pab.24
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 12:27:48 -0700 (PDT)
In-Reply-To: <20141029.150624.878155212768758630.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-29 at 15:06 -0400, David Miller wrote:

> However in the longer term I'd say that this value, if it is to have a
> limit, then such a limit should probably be scaled based upon the
> window size.


Yuchung and othres are working on a new way to handle reorders (RACK),
and should present the concept in next IETF meeting.

A linux patch should follow shortly.

High level idea is :

Decide when and what to retransmit based on the timing, instead of
sequence, relationships. This covers both original or retransmitted
packets.

On dupacks, wait a fraction of RTT before the repair process to both
allow reordering and relieve the network

Thanks
