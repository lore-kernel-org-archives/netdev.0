From: Avery Fay <avery@mixpanel.com>
Subject: Re: Invalid timestamp? causing tight ack loop (hundreds of thousands
 of packets / sec)
Date: Thu, 5 Feb 2015 15:25:05 -0800
Message-ID: <CAO-X30umnbpQG9mwj67ZUkxQpVcGgMMsP8SqY=_3ZeoTczjbmQ@mail.gmail.com>
References: <CAO-X30uMA7=DTm5KqqvYC5RVTM0bg9pKBO1nX1+6x_2pF_fWfA@mail.gmail.com>
	<1423036986.907.105.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAO-X30shOhH7tN+msRvbLreeUvZesKARqyU0Lnm3_xoeea9uaQ@mail.gmail.com>
	<1423052431.907.112.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:39972 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbbBEXZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 18:25:07 -0500
Received: by mail-qc0-f173.google.com with SMTP id m20so9092309qcx.4
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 15:25:06 -0800 (PST)
In-Reply-To: <1423052431.907.112.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 4, 2015 at 4:20 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Nice, something is really broken on this peer (not a linux one for
> sure), or some really buggy middlebox.
>
> The strange [P.] frame with no payload has a wrong sequence number
> anyway, so we send back a duplicate ack.

Thanks for this analysis. I've tried to reach out to the gatech NOC to
identify the device, but I haven't been able to get a response from
anyone (except general support, but they don't want to put me in touch
with someone who can help).

>
> Neal patches definitely would solve this issue.
>
>

Are these available anywhere? Or could they be made available? This
seems like a much better solution than disabling timestamps.

Avery
