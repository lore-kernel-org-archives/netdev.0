From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Invalid timestamp? causing tight ack loop (hundreds of thousands
 of packets / sec)
Date: Fri, 6 Feb 2015 16:16:25 -0500
Message-ID: <CADVnQyn20vWgfujSRRc+thud75hz0c1HG+vFEPhAu24c4-KivA@mail.gmail.com>
References: <CAO-X30uMA7=DTm5KqqvYC5RVTM0bg9pKBO1nX1+6x_2pF_fWfA@mail.gmail.com>
	<1423036986.907.105.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAO-X30shOhH7tN+msRvbLreeUvZesKARqyU0Lnm3_xoeea9uaQ@mail.gmail.com>
	<1423052431.907.112.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAO-X30umnbpQG9mwj67ZUkxQpVcGgMMsP8SqY=_3ZeoTczjbmQ@mail.gmail.com>
	<1423181871.31870.94.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Avery Fay <avery@mixpanel.com>, Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:47813 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757675AbbBFVQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 16:16:26 -0500
Received: by mail-qg0-f43.google.com with SMTP id i50so2262495qgf.2
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 13:16:25 -0800 (PST)
In-Reply-To: <1423181871.31870.94.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 5, 2015 at 7:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-02-05 at 15:25 -0800, Avery Fay wrote:
>
>> Are these available anywhere? Or could they be made available? This
>> seems like a much better solution than disabling timestamps.
>
> Neal is currently polishing a serie of 4 patches.
>
> This should be land to netdev shortly ;)

I emailed the patch series to the list. There is a a "[PATCH net-next
0/4] tcp: mitigate TCP ACK loops due to out-of-window validation
dupacks" cover letter with an overview. And you can find the patches
here:

http://patchwork.ozlabs.org/patch/437462/
http://patchwork.ozlabs.org/patch/437463/
http://patchwork.ozlabs.org/patch/437464/
http://patchwork.ozlabs.org/patch/437465/

Please feel free to try these out and let us know how they work for you.

Thanks!

neal
