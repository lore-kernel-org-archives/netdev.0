From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Fri, 3 Jan 2014 21:32:17 +0800
Message-ID: <CAPshTChj12sNe6f0TraABDemy6jCYRUzPjLXOa3kHu3PE9s6qg@mail.gmail.com>
References: <1388423651-12481-1-git-send-email-hkchu@google.com>
	<20140102.193026.342067029221260651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:63654 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185AbaACNcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 08:32:17 -0500
Received: by mail-qa0-f49.google.com with SMTP id ii20so433508qab.8
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 05:32:17 -0800 (PST)
In-Reply-To: <20140102.193026.342067029221260651.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 3, 2014 at 8:30 AM, David Miller <davem@davemloft.net> wrote:
> From: "H.K. Jerry Chu" <hkchu@google.com>
> Date: Mon, 30 Dec 2013 09:14:11 -0800
>
>> +extern struct list_head offload_base;
>
> Please add a programmatical interface to do the lookups you need
> rather than exporting this symbol externally.
>
> As best I can tell you're trying to "find gro receive by type"
> and "find gro complete by type".  So function signatures ought
> to look something like.
>
> struct packet_offload *gro_find_receive_by_type(__be16 type);
> struct packet_offload *gro_find_complete_by_type(__be16 type);
>
> Thanks.

Done. Will resubmit in a minute.

Thanks,

Jerry
