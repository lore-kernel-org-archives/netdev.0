From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: x25: remote-triggerable heap overflow in call user data
 processing
Date: Mon, 03 Oct 2011 07:45:31 +0200
Message-ID: <1317620731.3802.50.camel@edumazet-laptop>
References: <CA+nUz_K-mWFbFbSGKDFDGUufQmDA9+qW-0=1BDJ9QGe2Dxi-3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: matt d <mattjd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:52988 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807Ab1JCGe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 02:34:28 -0400
Received: by wwn22 with SMTP id 22so2910677wwn.1
        for <netdev@vger.kernel.org>; Sun, 02 Oct 2011 23:34:27 -0700 (PDT)
In-Reply-To: <CA+nUz_K-mWFbFbSGKDFDGUufQmDA9+qW-0=1BDJ9QGe2Dxi-3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 03 octobre 2011 =C3=A0 16:23 +1300, matt d a =C3=A9crit :
> Refer to the x25 packet layer's handling of incoming call user data,
> namely at these two locations, in x25_rx_call_request and
> x25_state1_machine:
> https://github.com/mirrors/linux/blob/master/net/x25/af_x25.c#L1039
> https://github.com/mirrors/linux/blob/master/net/x25/x25_in.c#L126
>=20
> Call user data from an incoming message is copied into
> (make)x25->calluserdata.cuddata buffers, which are 128 bytes long.
> However, the length copied is based on the remaining message length,
> and is not limited to the output buffer size. This allows a remote
> attacker to overflow data onto the heap.
>=20
> There is an appropriate constant defined for the length, but it
> seemingly isn't used there:
> https://github.com/mirrors/linux/blob/master/include/net/x25.h#L104
>=20
> It seems this issue was noticed some time ago:
> http://www.spinics.net/lists/linux-x25/msg00043.html
> http://patchwork.ozlabs.org/patch/23917/
> ...however nothing was done about the bigger problem.
>=20
> I have written a simple exploit for this vulnerability if it needs to
> be posted, however I think the problem is pretty straightforward to
> see as-is.

Please send a patch, it seems you have everything done to do it
properly ;)
