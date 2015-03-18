From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/6] inet: tcp listener refactoring, part 12
Date: Tue, 17 Mar 2015 20:40:41 -0700
Message-ID: <1426650041.25985.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426642351-26098-1-git-send-email-edumazet@google.com>
	 <20150317.220338.748443107477137734.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38889 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754671AbbCRDkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 23:40:43 -0400
Received: by igbue6 with SMTP id ue6so32624331igb.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 20:40:42 -0700 (PDT)
In-Reply-To: <20150317.220338.748443107477137734.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-17 at 22:03 -0400, David Miller wrote:

> Looks good, patch applied, thanks.
> 
> In patch #6 an extraneous final empty line was added to an inline
> function in net/request_sock.h, which I removed while applying this
> series.

Ah right, this was in reqsk_queue_hash_req().

Thanks for doing this David.
