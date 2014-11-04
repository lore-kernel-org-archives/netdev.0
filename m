From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: zero retrans_stamp if all retrans were acked
Date: Tue, 4 Nov 2014 14:03:30 -0500
Message-ID: <CADVnQykbFjodAyJomX8E5HZhOrP7kDxDS7vPNiam858B84vqCQ@mail.gmail.com>
References: <66a8a101a2bfe645432ec393d22b9da44b9739cf.1415110605.git.mleitner@redhat.com>
	<CADVnQynOfg6PDe0XYW+0uM+Kbqhv7RRTrEAJCrCEEY54Q6U8Eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:63444 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbaKDTDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 14:03:31 -0500
Received: by mail-qc0-f173.google.com with SMTP id x3so11436916qcv.18
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 11:03:31 -0800 (PST)
In-Reply-To: <CADVnQynOfg6PDe0XYW+0uM+Kbqhv7RRTrEAJCrCEEY54Q6U8Eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 4, 2014 at 1:51 PM, Neal Cardwell <ncardwell@google.com> wrote:
> In the meantime, Yuchung put together a nice packetdrill test case for
> this, so I'll run it on that version of the patch.

With the compilation issue fixed, Yuchung's packetdrill test passes.
So this looks good to me once the compilation issue with
tcp_any_retrans_done() is fixed.

neal
