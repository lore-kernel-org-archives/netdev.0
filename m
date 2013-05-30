From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 4/4 net-next] tcp: undo on DSACK during recovery
Date: Wed, 29 May 2013 20:50:26 -0400
Message-ID: <CADVnQy=mV9etEHPY_uM3mXQi0kbnpnEq+esmfumPVyGgLzACdw@mail.gmail.com>
References: <1369873214-29502-1-git-send-email-ycheng@google.com>
	<1369873214-29502-4-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Andreas Terzis <aterzis@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:62853 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab3E3Au1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 20:50:27 -0400
Received: by mail-ob0-f171.google.com with SMTP id dn14so331595obc.30
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 17:50:26 -0700 (PDT)
In-Reply-To: <1369873214-29502-4-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 29, 2013 at 8:20 PM, Yuchung Cheng <ycheng@google.com> wrote:
> If the receiver supports DSACK, sender can detect false recoveries and
> revert cwnd reductions triggered by either severe network reordering or
> concurrent reordering and loss event.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>
