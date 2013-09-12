From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: Re: 3.10.0 network trace
Date: Wed, 11 Sep 2013 21:51:58 -0400
Message-ID: <CA+5PVA4YmFVy=02Py2+1=BP4MbcCrUKphk7w+0-ahvMPxygt_g@mail.gmail.com>
References: <CA+rTEUPfP8ouJHbaFrO=-zktg2D06kYgXOq-LnmyKbbEzj-TmA@mail.gmail.com>
	<CA+rTEUMYihwm_5ado5q1ZrYovgM6=Yc99mSaO-dNUyj4XyTj_Q@mail.gmail.com>
	<CAK6E8=eNa72=LySKsgpnKd5A6CSkr0pbpet1X2g8em9Or=m7bg@mail.gmail.com>
	<CA+rTEUNfHvr-Zs1JWVQV+_7ygW5AP9UScePSBEM-dsi0h7nS=w@mail.gmail.com>
	<CAK6E8=eqFm5_nDMdzkt6WUJXmKVTOyGbt-WtVPHDWdrOdYK_Ow@mail.gmail.com>
	<CA+rTEUNkqngK5cTUPPKAYkNgF4P8JcHoRoaEgUzBUTvO+h5JXQ@mail.gmail.com>
	<CAK6E8=fefVLUorMKCqJGSnq6Sc9LOKp7eUyOnh6h8rcOcJtQNQ@mail.gmail.com>
	<CA+rTEUOXAH4TGMGvgBJ6FktA6E=hFhQmFHRf4Zaw5YJ6giOpOA@mail.gmail.com>
	<CA+5PVA5bDAz5a-TrM4ALA9vJz2JbE14VT7xM5=WqaRg=Ro0_xQ@mail.gmail.com>
	<CAK6E8=eRZQnPeVPpzcdzUtLqr0n2kjUQ2_JRE8_WXn3sSV2y9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Sterrett <michael@sterretts.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:59132 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635Ab3ILBv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 21:51:59 -0400
Received: by mail-wg0-f41.google.com with SMTP id a12so2471624wgh.4
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 18:51:58 -0700 (PDT)
In-Reply-To: <CAK6E8=eRZQnPeVPpzcdzUtLqr0n2kjUQ2_JRE8_WXn3sSV2y9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 11, 2013 at 12:32 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On Wed, Sep 11, 2013 at 5:49 AM, Josh Boyer <jwboyer@fedoraproject.org> wrote:
>> On Sun, Jul 21, 2013 at 9:36 PM, Michael Sterrett <michael@sterretts.net> wrote:
>>> Since upgraded to 3.10.1 which exhibits the same issue (probably not
>>> surprising).
>>>
>>> sysctl net.ipv4.tcp_frto=0 net.ipv4.tcp_early_retrans=3 seems to take
>>> care of it.
>>
>> We're still getting reports of this with 3.10.10 in Fedora [1].  At
>> least one of the reporters has said those sysctl settings didn't help.
>>
>> Is there anything else that can be gathered to help track this down?
> since frto=0 didn't help, I suspect it's either a bug introduced in
> the tail loss probe patch 9b717a8d (tcp: TLP loss detection) or other
> changes related loss recovery.
>
> could you try disable TLP by
> sysctl net.ipv4.tcp_frto=0 net.ipv4.tcp_early_retrans=1
>
> if it still does not work. disable any form of early retransmit by
> sysctl net.ipv4.tcp_frto=0 net.ipv4.tcp_early_retrans=0

Thanks.  I've asked the people in the bug to try those settings.

> if you can test a custom build kernel, please try this debugging patch.

I'll get the patch included in a test build for the tomorrow as well.

josh
