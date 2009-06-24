From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH] sky2: Fix a race condition in sky2_poll
Date: Wed, 24 Jun 2009 18:00:21 +0900
Message-ID: <392fb48f0906240200o29119c37g81d331627a2e2b2a@mail.gmail.com>
References: <392fb48f0906200101y5c83e853w170829f2ce40b274@mail.gmail.com>
	 <20090623.164544.114856885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:51485 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbZFXJAV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 05:00:21 -0400
Received: by fxm9 with SMTP id 9so592425fxm.37
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 02:00:22 -0700 (PDT)
In-Reply-To: <20090623.164544.114856885.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/6/24 David Miller <davem@davemloft.net>:
> From: Mike McCormack <mikem@ring3k.org>
> Date: Sat, 20 Jun 2009 17:01:25 +0900
>
>> Clear interrupt only when the status buffer is fully drained,
>> Make sure to clear interrupt when work_done =3D=3D work_limit
>> =C2=A0and the buffer is drained.
>
> Stephen's away on vacation for a bit so I wonder what to do
> about these two sky2 patches of your's.
>
> I guess it's not extremely urgent and we can thus wait for him
> to get back in a week or so and review your patches.

Hi Dave,

They're not urgent, so I'll test them some more, and work on a fix for
the sky2_up receiver hang issue until Stephen returns.

thanks,

Mike
