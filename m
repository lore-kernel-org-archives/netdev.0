From: Chetan Loke <chetanloke@gmail.com>
Subject: Re: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index>
	mapping
Date: Fri, 16 Jul 2010 16:15:44 -0400
Message-ID: <AANLkTineSDEEKY-9ve2maSBmPWBxkW5XmqnHlLtIOClx@mail.gmail.com>
References: <AANLkTilhSSh1kE5ZfqVDbBJJWdP3hDcXRffpQwdyMQua@mail.gmail.com>
	<20100716.124031.220080717.davem@davemloft.net>
	<AANLkTinAiJJqhrro8Jlrb0WgHzDSCx_dtWXL5N9ZKUbd@mail.gmail.com>
	<20100716.130445.149851386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, Chetan.Loke@netscout.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:33391 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966137Ab0GPUPq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 16:15:46 -0400
Received: by vws5 with SMTP id 5so2954571vws.19
        for <netdev@vger.kernel.org>; Fri, 16 Jul 2010 13:15:45 -0700 (PDT)
In-Reply-To: <20100716.130445.149851386.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 16, 2010 at 4:04 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Chetan Loke <chetanloke@gmail.com>
> Date: Fri, 16 Jul 2010 16:02:23 -0400
>
>> So all user space apps should replicate code when all of that can be
>> replaced at the cost of a single for-loop in a non fast-path code
>> within the kernel?
>
> When there is a way to do something already, we don't add "yet anothe=
r"
> way to do it. =C2=A0The kernel already suffers from API masterbation =
as-is.
>

Ok, what if, i) ifindex =3D=3D 0 in the call to SIOCGIFINDEX or ii) if =
the
ifindex is not found ? May be then in the else clause we could search
using the hw-addr before bailing out ;)? This way we can avoid adding
a new API. Still not a good idea?
