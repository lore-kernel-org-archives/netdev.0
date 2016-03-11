From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next v5] tcp: Add RFC4898 tcpEStatsPerfDataSegsOut/In
Date: Thu, 10 Mar 2016 16:04:47 -0800
Message-ID: <CANn89i+xa5h9WvAFV1vyrkXEX7=9ZNNEOp4+hbr5Of-Gjn0JBg@mail.gmail.com>
References: <1457635582-2979568-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Chris Rapier <rapier@psc.edu>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:36283 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932830AbcCKAEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 19:04:48 -0500
Received: by mail-yw0-f173.google.com with SMTP id g3so81552373ywa.3
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 16:04:48 -0800 (PST)
In-Reply-To: <1457635582-2979568-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 10:46 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> Per RFC4898, they count segments sent/received
> containing a positive length data segment (that includes
> retransmission segments carrying data).  Unlike
> tcpi_segs_out/in, tcpi_data_segs_out/in excludes segments
> carrying no data (e.g. pure ack).

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks.
