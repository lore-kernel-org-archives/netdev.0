From: =?UTF-8?Q?=E3=83=84_Leandro_Melo_de_Sales?= <leandroal@gmail.com>
Subject: Re: TCP packet size and delivery packet decisions
Date: Wed, 8 Sep 2010 13:03:46 -0300
Message-ID: <AANLkTi=Lq51fGBa4eH+eQHHiowNSCa01EbrfPWkBvRp1@mail.gmail.com>
References: <20100906.223010.173858342.davem@davemloft.net>
 <1283859552.2338.402.camel@edumazet-laptop> <AANLkTind7xGeYWOOdf1xnsZoJ5aFaChpD=fU7yFU2f-T@mail.gmail.com>
 <20100908.082454.104076446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:42067 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754892Ab0IHQEH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 12:04:07 -0400
Received: by gxk23 with SMTP id 23so104218gxk.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 09:04:06 -0700 (PDT)
In-Reply-To: <20100908.082454.104076446.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/9/8 David Miller <davem@davemloft.net>:
> From: =E3=83=84 Leandro Melo de Sales <leandroal@gmail.com>
> Date: Wed, 8 Sep 2010 11:06:43 -0300
>
>> =C2=A0 =C2=A0Good. I have tested and it is working... This is the ex=
actly
>> translation for code what I mentioned. Very nice...
>>
>> =C2=A0 =C2=A0Will this patch be applied?
>
> No because the patch is wrong, see the rest of the discussion.
>
> That line Eric is removing in his patch needs to be there
> because it is part of our implementation of sender side
> Silly Window Syndrome avoidance.
>
> We'll have to fix this another way.
>

Yes, just after I reply asking this question, I read the other
discussions, mainly the comments from Alexey about SWS and TSO.

Is someone working on trying to fix this another way?

Thank you,
Leandro.
