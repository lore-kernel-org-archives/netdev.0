From: Neal Cardwell <ncardwell@google.com>
Subject: Re: inet_diag_dump_icsk() change seems bogus...
Date: Sun, 2 Feb 2014 13:59:06 -0500
Message-ID: <CADVnQymV9R-f3ANtFxbBnsKtD3ytO7QwrOEz7cJAkVkn34ADKQ@mail.gmail.com>
References: <20140202.004538.1011276314292086521.davem@davemloft.net>
	<CADVnQynq6tfd6Hdg0iqD4Wpm805mVXwFT-VUCsWT6YUxo2=wbQ@mail.gmail.com>
	<1391367154.28432.91.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:52941 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbaBBS7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Feb 2014 13:59:07 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so3187493eei.21
        for <netdev@vger.kernel.org>; Sun, 02 Feb 2014 10:59:06 -0800 (PST)
In-Reply-To: <1391367154.28432.91.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 2, 2014 at 1:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2014-02-02 at 10:43 -0500, Neal Cardwell wrote:
>> Hi David,
>>
>> That was true in 3.12 and earlier, but AFAICT since Eric's 05dbc7b
>> ("tcp/dccp: remove twchain") in 3.13-rc1, there is no head->twchain,
>> and instead all the connections (both tcp_sock and timewait flavor)
>> are on the head->chain, so that we do need to check for timewait
>> sockets. :-)
>
>
> Note that Neal fix needs a different form for stable trees.
>
> Thats maybe David concern ;)

Ah, makes sense. :-) I have a tested version of the patch for pre-3.13
kernels if anyone is interested in that.

neal
