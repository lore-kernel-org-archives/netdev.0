From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: fix bogus RTT for CC when retransmissions
 are acked
Date: Sun, 12 Apr 2015 10:13:33 -0400
Message-ID: <CADVnQyk7ZmB6OnCjpZqPy+7_OtUBLT0z_DszowEpu_UpMYpooA@mail.gmail.com>
References: <1428711469-5328-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:32865 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbbDLONe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 10:13:34 -0400
Received: by qkx62 with SMTP id 62so128296385qkx.0
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 07:13:34 -0700 (PDT)
In-Reply-To: <1428711469-5328-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 10, 2015 at 8:17 PM, Kenneth Klette Jonassen
<kennetkl@ifi.uio.no> wrote:
> Since retransmitted segments are not used for RTT estimation, previously
> SACKed segments present in the rtx queue are used. This estimation can be
> several times larger than the actual RTT. When a cumulative ack covers both
> previously SACKed and retransmitted segments, CC may thus get a bogus RTT.
>
> Such segments previously had an RTT estimation in tcp_sacktag_one(), so it
> seems reasonable to not reuse them in tcp_clean_rtx_queue() at all.
>
> Afaik, this has had no effect on SRTT/RTO because of Karn's check.
>
> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>

Acked-by: Neal Cardwell <ncardwell@google.com>
Tested-by: Neal Cardwell <ncardwell@google.com>

neal
