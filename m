From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH net] tcp: zero retrans_stamp if all retrans were acked
Date: Tue, 04 Nov 2014 17:12:17 -0200
Message-ID: <54592511.8040407@redhat.com>
References: <66a8a101a2bfe645432ec393d22b9da44b9739cf.1415110605.git.mleitner@redhat.com>	<CADVnQynOfg6PDe0XYW+0uM+Kbqhv7RRTrEAJCrCEEY54Q6U8Eg@mail.gmail.com> <CADVnQykbFjodAyJomX8E5HZhOrP7kDxDS7vPNiam858B84vqCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52758 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034AbaKDTMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 14:12:25 -0500
In-Reply-To: <CADVnQykbFjodAyJomX8E5HZhOrP7kDxDS7vPNiam858B84vqCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04-11-2014 17:03, Neal Cardwell wrote:
> On Tue, Nov 4, 2014 at 1:51 PM, Neal Cardwell <ncardwell@google.com> wrote:
>> In the meantime, Yuchung put together a nice packetdrill test case for
>> this, so I'll run it on that version of the patch.
>
> With the compilation issue fixed, Yuchung's packetdrill test passes.
> So this looks good to me once the compilation issue with
> tcp_any_retrans_done() is fixed.

Awesome! Thanks. Sending it now.

Marcelo
