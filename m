From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCHv2] net/ipv6: add sysctl option accept_ra_hop_limit
Date: Wed, 29 Jul 2015 17:58:31 +0800
Message-ID: <CAPwn2JT21NSjJ8vxQ98TPaEK1HN-y9qM30cYRyUdHYaMGPgKZw@mail.gmail.com>
References: <1437978942-7047-1-git-send-email-liuhangbin@gmail.com>
	<55B6C3AF.1050504@miraclelinux.com>
	<CAPwn2JSk0P8n+aSxTGiU0Q2RSSbZ52NVZxOS+yURpor2YQVySQ@mail.gmail.com>
	<55B6FDD0.4020904@miraclelinux.com>
	<CAPwn2JTRvN7pzSxz4TMXC7FNWxbH0PYPPoOjpRpM_rCigoiFeg@mail.gmail.com>
	<55B836FA.7070106@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: network dev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:33482 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbbG2J6c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 05:58:32 -0400
Received: by oixx19 with SMTP id x19so2361738oix.0
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 02:58:31 -0700 (PDT)
In-Reply-To: <55B836FA.7070106@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-07-29 10:14 GMT+08:00 YOSHIFUJI Hideaki
<hideaki.yoshifuji@miraclelinux.com>:
>>>> May be we use a =E2=80=9Chop limit range" instead? How do you thin=
k?
>>>
>>> I think name of sysctl is the same as you suggested and change the
>>> semantics.  default value is 0 to accept all hotlimit value
>>> as before and people can set it to 32 (for example) to reject
>>> too-small hoplimit (0-31).
>>
>> OK, then I will try submit a "minimum hop limit", thanks for your su=
ggestion :)
>
> accept_ra_min_hop_limit would be better as we have
> accept_ra_rt_info_max_plen.
>
Opps, I missed this mail and send a [PATCH] net/ipv6: add sysctl
option min_hop_limit...
I will send a [PATCHv3] net/ipv6: add sysctl option
accept_ra_min_hop_limit as this patch's
follow up. Sorry for the version confusion.

Thanks
Hangbin
