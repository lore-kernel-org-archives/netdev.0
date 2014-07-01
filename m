From: Octavian Purdila <octavian.purdila@intel.com>
Subject: Re: [PATCH net-next] tcp: switch snt_synack back to measuring
 transmit time of first SYNACK
Date: Tue, 1 Jul 2014 11:33:10 +0300
Message-ID: <CAE1zotL1kwk3NfzEAYaM5fdOJihOfn04MQz4qGaVs3LybbVtvg@mail.gmail.com>
References: <1404155389-22927-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>, Jerry Chu <hkchu@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:57604 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755515AbaGAIdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 04:33:12 -0400
Received: by mail-we0-f174.google.com with SMTP id u57so9123047wes.5
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 01:33:10 -0700 (PDT)
In-Reply-To: <1404155389-22927-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 30, 2014 at 10:09 PM, Neal Cardwell <ncardwell@google.com> wrote:
> Always store in snt_synack the time at which the server received the
> first client SYN and attempted to send the first SYNACK.
>
> Recent commit aa27fc501 ("tcp: tcp_v[46]_conn_request: fix snt_synack
> initialization") resolved an inconsistency between IPv4 and IPv6 in
> the initialization of snt_synack. This commit brings back the idea
> from 843f4a55e (tcp: use tcp_v4_send_synack on first SYN-ACK), which
> was going for the original behavior of snt_synack from the commit
> where it was added in 9ad7c049f0f79 ("tcp: RFC2988bis + taking RTT
> sample from 3WHS for the passive open side") in v3.1.
>
> In addition to being simpler (and probably a tiny bit faster),
> unconditionally storing the time of the first SYNACK attempt has been
> useful because it allows calculating a performance metric quantifying
> how long it took to establish a passive TCP connection.
>

Acked-by: Octavian Purdila <octavian.purdila@intel.com>
