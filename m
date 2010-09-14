From: Michal Suchanek <hramrach@centrum.cz>
Subject: Re: [Bugme-new] [Bug 18492] New: kernel softirq warning on boot
Date: Tue, 14 Sep 2010 22:45:19 +0200
Message-ID: <AANLkTinE50xFx9nShGBeOf483G2FhogO-BCj=dfHBZS7@mail.gmail.com>
References: <bug-18492-10286@https.bugzilla.kernel.org/> <20100914120738.6a658f69.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:55057 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754275Ab0INUpk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 16:45:40 -0400
Received: by gxk23 with SMTP id 23so2538870gxk.19
        for <netdev@vger.kernel.org>; Tue, 14 Sep 2010 13:45:39 -0700 (PDT)
In-Reply-To: <20100914120738.6a658f69.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 September 2010 21:07, Andrew Morton <akpm@linux-foundation.org> w=
rote:
>
> (switched to email. =C2=A0Please respond via emailed reply-to-all, no=
t via the
> bugzilla web interface).
>
> On Tue, 14 Sep 2010 15:19:30 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D18492
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Summary: kernel softirq war=
ning on boot
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Product: Drivers
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Version: 2.5
>> =C2=A0 =C2=A0 Kernel Version: 2.6.36-rc4
>
> Looks like a post-2.6.35 regression. =C2=A0I'd be looking at the

Indeed, I found a log from booting 2.6.35 kernel while trying to work
around anouther issue and the warning did not show in it.

> rcu_read_unlock_bh() in netpoll_rx(), added by "netpoll: Fix RCU
> usage".

Do you mean de85d99eb7b595f6751550184b94c1e2f74a828b?

I am not sure reverting just that would work, nor that the kernel
around that point is in shape for trying on a system I would want to
still use. It's way back in history for a kernel which is just to be
released.

Thanks

Michal
