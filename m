From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: net-timestamp: MSG_TSTAMP flags and bytestream support
Date: Wed, 25 Jun 2014 09:32:15 +0200
Message-ID: <20140625073215.GB5566@localhost.localdomain>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:62689 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbaFYHco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 03:32:44 -0400
Received: by mail-we0-f179.google.com with SMTP id w62so1472463wes.24
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 00:32:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1403624632-17327-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2014 at 11:43:45AM -0400, Willem de Bruijn wrote:
> This patchset extends socket timestamping in a number of related ways.
> Most notably:
> 
> 2 MSG_TSTAMP: request a single tx timestamp by passing a flag on send
> 6 MSG_TSTAMP_ENQ: request a tx timestamp before traffic shaping.
> 5 MSG_TSTAMP_ACK: request a tx timestamp after acknowledgements (TCP)
> 4 TCP support for all three flags

Can you tell us a bit about the use case?  It sounds like that this is
for performance monitoring.

> Each individual patch commit message gives more detail about the
> specific feature.
> 
> The other patches support the main feature:
> 1 explicitly define the timestamp response API
> 3 optionally avoid looping large packets onto the socket error queue.
> 7 documentation and an example test.

I think #2 and #3 could be improvements to the so_timestamping api.

The others probably need their own, separate api. I can't imagine
wanting to mix so_timestamping with these new tcp time stamps, but
maybe you want to explain the expected scenario?

Thanks,
Richard
