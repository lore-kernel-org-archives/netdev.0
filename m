From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ppp, "Features changed" flooding the log
Date: Fri, 20 May 2011 16:00:27 +0200
Message-ID: <1305900027.3173.16.camel@edumazet-laptop>
References: <a08c037f093701d9a2d187d04ac85fee@visp.net.lb>
	 <e04d91916983d0a9274087cd2f5ef64d@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45827 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828Ab1ETOAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 10:00:30 -0400
Received: by wwa36 with SMTP id 36so4050803wwa.1
        for <netdev@vger.kernel.org>; Fri, 20 May 2011 07:00:29 -0700 (PDT)
In-Reply-To: <e04d91916983d0a9274087cd2f5ef64d@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 20 mai 2011 =C3=A0 16:44 +0300, Denys Fedoryshchenko a =C3=A9=
crit :

>  And as i see GRO enabled there, i guess it can be harmful for shaper=
s,=20
>  how to disable it?
>  NewNet-PPPoE ~ # ethtool -K ppp0 gro off
>  Cannot set device GRO settings: Operation not supported
>  Or there is no need for that?
> --

No need, since GRO sits on top of NAPI (physical devices)

ppp is done after this layer, frames are directly delivered to IP layer=
=2E

But yes, this log flood is nasty.


