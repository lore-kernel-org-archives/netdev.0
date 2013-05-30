From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 1/4 net-next] tcp: consolidate PRR packet accounting
Date: Wed, 29 May 2013 20:41:39 -0400
Message-ID: <CADVnQykHsqcLJV2gvQqMMLT-XUZZaGbAvTwmw1JJ4z5NE=aqAg@mail.gmail.com>
References: <1369873214-29502-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Andreas Terzis <aterzis@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:59714 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab3E3Alk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 20:41:40 -0400
Received: by mail-ob0-f174.google.com with SMTP id wd20so5322403obb.5
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 17:41:39 -0700 (PDT)
In-Reply-To: <1369873214-29502-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 29, 2013 at 8:20 PM, Yuchung Cheng <ycheng@google.com> wrote:
> This patch series fix an undo bug in fast recovery: the sender
> mistakenly undos the cwnd too early but continue fast retransmits
> until all pending data are acked. This also multiplicates the SNMP
> stat PARTIALUNDO events by the degree of the network reordering.
>
> The first patch prepares the fix by consolidating the accounting
> of newly_acked_sacked in tcp_cwnd_reduction(), instead of updating
> newly_acked_sacked everytime sacked_out is adjusted.  Also pass
> acked and prior_unsacked as const type because they are readonly
> in the rest of recovery processing.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>
