From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] netlink: use the appropriate namespace pid
Date: Wed, 24 Mar 2010 09:58:57 +0200
Message-ID: <b6fcc0a1003240058i524c95eere17c1349d14267b1@mail.gmail.com>
References: <20100320013850.GA13239@boeing.com>
	 <20100321.213022.22037430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: thomas.goff@boeing.com, netdev@vger.kernel.org,
	adobriyan@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:45397 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218Ab0CXIHj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 04:07:39 -0400
Received: by pzk32 with SMTP id 32so806958pzk.4
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 01:07:38 -0700 (PDT)
In-Reply-To: <20100321.213022.22037430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 22, 2010 at 6:30 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Tom Goff <thomas.goff@boeing.com>
> Date: Fri, 19 Mar 2010 18:38:50 -0700
>
>> This was included in OpenVZ kernels but wasn't integrated upstream.
>>>From git://git.openvz.org/pub/linux-2.6.24-openvz:
>>
>> =A0 =A0 =A0 commit 5c69402f18adf7276352e051ece2cf31feefab02
>> =A0 =A0 =A0 Author: Alexey Dobriyan <adobriyan@openvz.org>
>> =A0 =A0 =A0 Date: =A0 Mon Dec 24 14:37:45 2007 +0300
>>
>> =A0 =A0 =A0 =A0 =A0 netlink: fixup ->tgid to work in multiple PID na=
mespaces
>>
>> Signed-off-by: Tom Goff <thomas.goff@boeing.com>
>
> Well, at least CC: the person whose patches your pushing
> around, maybe they had a reason to not include it? =A0The
> openvz guys have been extremely good about submitting
> their stuff so they deserve the benefit of the doubt.
>
> Alexey, can you review Tom's namespace patches in this
> set?

ACK tgid patch, should have sent it myself long ago.
