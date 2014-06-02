From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH RFC]: new-CWV for Linux
Date: Mon, 2 Jun 2014 11:50:14 -0700
Message-ID: <CADVnQymKpdepbykfz-3GTvqA9zGwmF1PeqZyzckKchZYHGUorA@mail.gmail.com>
References: <CAKUix-6-DM=qprmeNQ7fKtGZJocjrCb=QRNFqNT7WC1DmYAS9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuchung Cheng <ycheng@google.com>, Netdev <netdev@vger.kernel.org>,
	Gorry Fairhurst <gorry@erg.abdn.ac.uk>,
	"Hossain, Ziaul" <ziaul.hossain@abdn.ac.uk>, tom@erg.abdn.ac.uk
To: r.secchi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:33565 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbaFBSuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 14:50:15 -0400
Received: by mail-we0-f179.google.com with SMTP id q59so5732203wes.10
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 11:50:14 -0700 (PDT)
In-Reply-To: <CAKUix-6-DM=qprmeNQ7fKtGZJocjrCb=QRNFqNT7WC1DmYAS9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 2, 2014 at 11:34 AM, Raffaello Secchi <r.secchi@gmail.com> wrote:
> Hi Yuchung,
>
> We modified the newcwv patch so to be CC independent and
> comply with draft-ietf-tcpm-newcwv-06. We submit this patch to this list
> hoping that could be incorporated in mainstream kernel.
>
> We tested both with Reno and Cubic by replaying TMIX traces of Internet web
> traffic sessions over our Netem testbed. We saw clear latency improvements when
> traces presented gap-burst behaviour of at least 100 KB after the idle period.
>
> For example the latency of individual HTTP request/responses was reduced of
> about 1 sec when we used an emulated path of 4Mbps link and 100ms RTT delay.
>
> We also experimented with combining this with the Linux FQ scheduler and under
> some patterns of traffic this reduced the number of packet drops - indicating
> that this may be useful.
>
> We would be grateful if you or someone from your group could consider
> this code and give us an independent evaluation.
>
> Thanks,
>
> Raffaello
>
> Signed-off-by: Raffaello Secchi <raffaello@erg.abdn.ac.uk>
> Reviewed-by: Tom Jones <tom@erg.abdn.ac.uk>

We are interested in experimenting with this, but the patch seems to
have formatting issues, probably due to the email client corrupting
formatting.

Assuming you have this in the form of a git commit, can you please try
something like:

rm 0001-*.patch
git format-patch --subject-prefix='PATCH RFC' HEAD~1
./scripts/checkpatch.pl 0001-*.patch
git send-email --to 'David Miller <davem@davemloft.net>' --cc
'netdev@vger.kernel.org'  0001-*.patch

Thanks!

neal
