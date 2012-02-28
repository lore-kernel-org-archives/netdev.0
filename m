From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: fix tcp_shifted_skb() adjustment of lost_cnt_hint
 for FACK
Date: Mon, 27 Feb 2012 22:45:31 -0500
Message-ID: <CADVnQy=YkDOGX66ycPuPCy9TigXN1k4cDpSrK1Wq8zK_xBYi8A@mail.gmail.com>
References: <alpine.DEB.2.00.1202280127490.17924@melkinpaasi.cs.helsinki.fi>
	<alpine.DEB.2.00.1202280141380.18668@melkinpaasi.cs.helsinki.fi>
	<CADVnQym_a=QDyjGX=L6-o3orxPdKJOwVZNfutaW5ZHAt=aB21A@mail.gmail.com>
	<20120227.215820.1289745868005567561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ilpo.jarvinen@helsinki.fi, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, nanditad@google.com, ycheng@google.com,
	therbert@google.com, subramanian.vijay@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:48299 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299Ab2B1Dpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 22:45:32 -0500
Received: by iagj37 with SMTP id j37so667544iag.19
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 19:45:31 -0800 (PST)
In-Reply-To: <20120227.215820.1289745868005567561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2012 at 9:58 PM, David Miller <davem@davemloft.net> wrote:
> From: Neal Cardwell <ncardwell@google.com>
> Date: Mon, 27 Feb 2012 21:40:03 -0500
>
>> Yes, I agree that it would make sense to hold off on adding these
>> three 3.3-rc4 commits to the stable tree:
>>
>> cc9a672ee522d4805495b98680f4a3db5d0a0af9
>>
>> daef52bab1fd26e24e8e9578f8fb33ba1d0cb412
>>
>> 0af2a0d0576205dda778d25c6c344fc6508fc81d
>>
>> It would make sense to let the dust settle a bit more before adding
>> those to the stable tree.
>>
>> The same goes for the http://patchwork.ozlabs.org/patch/143114/ patch
>> (under review) that is in the same area of the code.
>
> I totally disagree and I have submitted those fixes to -stable
> already and do not plan to rescind those submissions at all.

OK, sounds good to me. In that case I think it would be good to have
the http://patchwork.ozlabs.org/patch/143114/ patch in -stable as
well, since having just the three patches above would leave us with a
known reordering issue.

neal
