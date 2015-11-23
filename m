From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Mon, 23 Nov 2015 12:02:21 -0800
Message-ID: <CALx6S350GV8BKVjwBCATc2G4-BB4K+bh+UBWKOazxm8e8XXb-g@mail.gmail.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
	<1448272388.3983270.447381049.07BA3A5C@webmail.messagingengine.com>
	<CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
	<20151123.145433.1554000376541433305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>, davewatson@fb.com,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35026 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932192AbbKWUCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 15:02:21 -0500
Received: by igl9 with SMTP id 9so58872551igl.0
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 12:02:21 -0800 (PST)
In-Reply-To: <20151123.145433.1554000376541433305.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2015 at 11:54 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Mon, 23 Nov 2015 09:33:44 -0800
>
>> The TCP PSH flag is not defined for message delineation (neither is
>> urgent pointer). We can't change that (many people have tried to add
>> message semantics to TCP protocol but have always failed miserably).
>
> Agreed.
>
> My only gripe with kcm right now is a lack of a native sendpage.
> We should be able to zero copy data through KCM streams without
> any problems whatsoever.

Right, there is no reason zero copy won't work here. I was just trying
minimize the initial implementation small for reviewability.
