From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2] tcp: fix infinite cwnd in tcp_complete_cwr()
Date: Mon, 30 Apr 2012 12:25:56 -0400
Message-ID: <CADVnQymFjqqT__kCN-0vqz+jqBLez7aoQZ14KEV5=m=Ed=Nayw@mail.gmail.com>
References: <1335801618-31498-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:40267 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755126Ab2D3Q0A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 12:26:00 -0400
Received: by yhmm54 with SMTP id m54so1501251yhm.19
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 09:25:59 -0700 (PDT)
In-Reply-To: <1335801618-31498-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 30, 2012 at 12:00 PM, Yuchung Cheng <ycheng@google.com> wro=
te:
> When the cwnd reduction is done, ssthresh may be infinite
> if TCP enters CWR via ECN or F-RTO. If cwnd is not undone, i.e.,
> undo_marker is set, tcp_complete_cwr() falsely set cwnd to the
> infinite ssthresh value. The correct operation is to keep cwnd
> intact because it has been updated in ECN or F-RTO.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
> ChangeLog since v1:
> =A0- Add snd_cwnd_stamp timestamping in CWR mode
>
> =A0net/ipv4/tcp_input.c | =A0 =A09 ++++++---
> =A01 files changed, 6 insertions(+), 3 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
