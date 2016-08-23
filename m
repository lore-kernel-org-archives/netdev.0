From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] udp: fix poll() issue with zero sized packets
Date: Tue, 23 Aug 2016 16:39:41 -0700 (PDT)
Message-ID: <20160823.163941.1551130952096100509.davem@davemloft.net>
References: <f4d8b317-72bd-382d-f758-5fa997f1637b@redhat.com>
        <1471985604.14381.48.camel@edumazet-glaptop3.roam.corp.google.com>
        <1471985973.14381.54.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: labbott@redhat.com, samanthakumar@google.com, willemb@google.com,
        netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55787 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753017AbcHWXk0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 19:40:26 -0400
In-Reply-To: <1471985973.14381.54.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Aug 2016 13:59:33 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Laura tracked poll() [and friends] regression caused by commit
> e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
> 
> udp_poll() needs to know if there is a valid packet in receive queue,
> even if its payload length is 0.
> 
> Change first_packet_length() to return an signed int, and use -1
> as the indication of an empty queue.
> 
> Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
> Reported-by: Laura Abbott <labbott@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Laura Abbott <labbott@redhat.com>
> ---
> v2: fix the comment/doc (Willem)

Applied and queued up for -stable, thanks.
