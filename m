From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCHv3, ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Mon, 02 Feb 2015 10:02:50 +0100
Message-ID: <54CF3D3A.5040607@6wind.com>
References: <1422349230-17394-1-git-send-email-fan.du@intel.com> <54CA0B9F.8080104@6wind.com> <20150202084443.GS13046@secunet.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:42432 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932818AbbBBJCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 04:02:54 -0500
Received: by mail-we0-f181.google.com with SMTP id k48so37717229wev.12
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 01:02:52 -0800 (PST)
In-Reply-To: <20150202084443.GS13046@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/02/2015 09:44, Steffen Klassert a =E9crit :
> On Thu, Jan 29, 2015 at 11:29:51AM +0100, Nicolas Dichtel wrote:
[snip]
>>
>> The point I try to make is that patching userland apps allows to use=
 xfrm on a
>> 32bits userland / 64bits kernel.
>
> Ugh, I did not know that this is used that way. Which applications do=
 this?
> So the situation is worse than I thought. What happens to such applic=
ations
> if we add a compat layer in the kernel? I'd guess they will break, ri=
ght?
A compat layer will be perfect. I just wanted to highlight the fact tha=
t without
this patch, it's possible to have a workaround to use netlink-xfrm and =
after it,
it will be impossible.

>
>>
>> If I understand well your patch, it will not be possible anymore, al=
l messages
>> will be rejected. And this may break existing apps.
>
> This patch would have been a quick solution without the case you
> mentioned. Now I fear we can't fix all cases, something will remain
> broken.
>
I think you're right, but having a proper solution is probably the best=
=2E
