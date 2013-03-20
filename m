From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 3/4] filter: add ANC_PAY_OFFSET instruction
 for loading payload start offset
Date: Wed, 20 Mar 2013 13:16:22 -0400 (EDT)
Message-ID: <20130320.131622.87230078711098980.davem@davemloft.net>
References: <1363711172-9728-1-git-send-email-dborkman@redhat.com>
	<1363711172-9728-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685Ab3CTRQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:16:24 -0400
In-Reply-To: <1363711172-9728-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 19 Mar 2013 17:39:31 +0100

> It is very useful to do dynamic truncation of packets. In particular,
> we're interested to push the necessary header bytes to the user space and
> cut off user payload that should probably not be transferred for some reasons
> (e.g. privacy, speed, or others). With the ancillary extension PAY_OFFSET,
> we can load it into the accumulator, and return it. E.g. in bpfc syntax ...
> 
>         ld #poff        ; { 0x20, 0, 0, 0xfffff034 },
>         ret a           ; { 0x16, 0, 0, 0x00000000 },
> 
> ... as a filter will accomplish this without having to do a big hackery in
> a BPF filter itself. Follow-up JIT implementations are welcome.
> 
> Thanks to Eric Dumazet for suggesting and discussing this during the
> Netfilter Workshop in Copenhagen.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
