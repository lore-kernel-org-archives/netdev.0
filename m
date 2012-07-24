From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: Re: [PATCH] ppp: add 64 bit stats
Date: Mon, 23 Jul 2012 21:53:28 -0400
Message-ID: <CABF+-6Vko_T2RCsk1KVouB8a+8Ms_aLEoA-Xet1nxB8bnZAxMA@mail.gmail.com>
References: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
	<1343020585.2626.10054.camel@edumazet-glaptop>
	<CABF+-6WHqzXhvv9etdAqsamZirbWxWJEsnU-CQ1H8tvynCTOZA@mail.gmail.com>
	<1343059184.2626.11027.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:62390 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755225Ab2GXBxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 21:53:30 -0400
Received: by vbbff1 with SMTP id ff1so5336995vbb.19
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 18:53:29 -0700 (PDT)
In-Reply-To: <1343059184.2626.11027.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 23, 2012 at 11:59 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Would proper synchronization in this case just be wrapping the updates
>> in a spin_lock/spin_unlock?
>
> Would be fine (if the proper BH safe variant is used), or you could also
> use atomic64_t.

Which would you recommend, spin locks or atomic64_t?

atomic64_t seems like it would be simpler.
