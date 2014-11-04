From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net] tcp: zero retrans_stamp if all retrans were acked
Date: Tue, 4 Nov 2014 15:10:31 -0500
Message-ID: <CADVnQymMioK0USNpaOF2Kb4+zMTDrjJ7r=5Bu51LbirVQPnzyw@mail.gmail.com>
References: <CADVnQykbFjodAyJomX8E5HZhOrP7kDxDS7vPNiam858B84vqCQ@mail.gmail.com>
	<f58c4b02028e0750e583518608891d20742c0f38.1415128437.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:33004 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbaKDUKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 15:10:32 -0500
Received: by mail-qc0-f175.google.com with SMTP id b13so12979748qcw.34
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 12:10:31 -0800 (PST)
In-Reply-To: <f58c4b02028e0750e583518608891d20742c0f38.1415128437.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 4, 2014 at 2:15 PM, Marcelo Ricardo Leitner
<mleitner@redhat.com> wrote:
...
> Therefore, now we clear retrans_stamp as soon as all data during the
> loss window is fully acked.
>
> Reported-by: Ueki Kohei
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> ---
>
> Notes:
>     v1->v2: fixed compilation issue noticed by Neal
>
>  net/ipv4/tcp_input.c | 60 +++++++++++++++++++++++++++-------------------------
>  1 file changed, 31 insertions(+), 29 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>
Tested-by: Neal Cardwell <ncardwell@google.com>

Code looks fine, and it passes Yuchung's packetdrill test case for this.

Thanks for finding and fixing this, Marcelo.

neal
