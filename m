From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/8] tcp: accept SOF_TIMESTAMPING_OPT_ID for
 passive TFO
Date: Fri, 01 Apr 2016 08:44:23 -0700
Message-ID: <1459525463.6473.278.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459523080-29329-1-git-send-email-soheil.kdev@gmail.com>
	 <1459523080-29329-3-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, willemb@google.com,
	edumazet@google.com, ycheng@google.com, ncardwell@google.com,
	kafai@fb.com, Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35647 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbcDAPo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:44:26 -0400
Received: by mail-pa0-f53.google.com with SMTP id td3so93307756pab.2
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:44:26 -0700 (PDT)
In-Reply-To: <1459523080-29329-3-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 11:04 -0400, Soheil Hassas Yeganeh wrote:
> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> SOF_TIMESTAMPING_OPT_ID is set to get data-independent IDs
> to associate timestamps with send calls. For TCP connections,
> tp->snd_una is used as the starting point to calculate
> relative IDs.
> 
> This socket option will fail if set before the handshake on a
> passive TCP fast open connection with data in SYN or SYN/ACK,
> since setsockopt requires the connection to be in the
> ESTABLISHED state.
> 
> To address these, instead of limiting the option to the
> ESTABLISHED state, accept the SOF_TIMESTAMPING_OPT_ID option as
> long as the connection is not in LISTEN or CLOSE states.


Acked-by: Eric Dumazet <edumazet@google.com>
