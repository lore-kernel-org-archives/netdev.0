From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next] sctp: prepare asoc stream for stream reconf
Date: Fri, 06 Jan 2017 21:07:41 -0500 (EST)
Message-ID: <20170106.210741.1161324031407112453.davem@davemloft.net>
References: <efd6462731ca0b18a3039f9537dda61e0ed72430.1483712313.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49996 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932082AbdAGCHn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 21:07:43 -0500
In-Reply-To: <efd6462731ca0b18a3039f9537dda61e0ed72430.1483712313.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri,  6 Jan 2017 22:18:33 +0800

> sctp stream reconf, described in RFC 6525, needs a structure to
> save per stream information in assoc, like stream state.
> 
> In the future, sctp stream scheduler also needs it to save some
> stream scheduler params and queues.
> 
> This patchset is to prepare the stream array in assoc for stream
> reconf. It defines sctp_stream that includes stream arrays inside
> to replace ssnmap.
> 
> Note that we use different structures for IN and OUT streams, as
> the members in per OUT stream will get more and more different
> from per IN stream.
> 
> v1->v2:
>   - put these patches into a smaller group.
> v2->v3:
>   - define sctp_stream to contain stream arrays, and create stream.c
>     to put stream-related functions.
>   - merge 3 patches into 1, as new sctp_stream has the same name
>     with before.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.
