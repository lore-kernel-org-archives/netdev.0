From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 3/4] filter: add ANC_PAY_OFFSET instruction
 for loading payload start offset
Date: Tue, 19 Mar 2013 08:04:52 -0700
Message-ID: <1363705492.2558.5.camel@edumazet-glaptop>
References: <cover.1363702456.git.dborkman@redhat.com>
	 <c5924543d43d3870840806cb951b385135d1c0c4.1363702456.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jasowang@redhat.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:55110 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081Ab3CSPE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 11:04:56 -0400
Received: by mail-da0-f41.google.com with SMTP id w4so369206dam.0
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 08:04:55 -0700 (PDT)
In-Reply-To: <c5924543d43d3870840806cb951b385135d1c0c4.1363702456.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-19 at 15:34 +0100, Daniel Borkmann wrote:
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
> ---


Thanks a lot Daniel

Acked-by: Eric Dumazet <edumazet@google.com>
