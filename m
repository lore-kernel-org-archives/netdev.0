From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: validate chunk len before actually using it
Date: Sat, 29 Oct 2016 11:57:35 -0400 (EDT)
Message-ID: <20161029.115735.1305731447719654765.davem@davemloft.net>
References: <06d1d4f21f959784823d7c7e31c3ea7e7360cb99.1477410525.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com,
        syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
        edumazet@google.com, dvyukov@google.com, andreyknvl@google.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48106 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753633AbcJ2P5i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 11:57:38 -0400
In-Reply-To: <06d1d4f21f959784823d7c7e31c3ea7e7360cb99.1477410525.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Tue, 25 Oct 2016 14:27:39 -0200

> Andrey Konovalov reported that KASAN detected that SCTP was using a slab
> beyond the boundaries. It was caused because when handling out of the
> blue packets in function sctp_sf_ootb() it was checking the chunk len
> only after already processing the first chunk, validating only for the
> 2nd and subsequent ones.
> 
> The fix is to just move the check upwards so it's also validated for the
> 1st chunk.
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
> 
> Hi. Please consider this to -stable too. Thanks

Applied and queued up for -stable, thanks!
