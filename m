From: Gabriel Beddingfield <gabrbedd@gmail.com>
Subject: Re: Miscalculated TCP ACK ?
Date: Mon, 22 Aug 2011 19:41:45 -0500
Message-ID: <4E52F749.4000204@gmail.com>
References: <CAPbw_hwQSXtmFSxK49jDDgF2LuG8=cu5t=ZjQ_aO7=M9fm9xeA@mail.gmail.com>	 <1314031128.2307.110.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <CAEnQRZAB=tKwr0wX2OrpG8iq5VaJPmssHEfC3U62bz1XL_2FHw@mail.gmail.com>	 <CAPbw_hy7xjhWSsiHnB9HN+ROCEUNzOS8aPsFwjvdY4FY+pRVjw@mail.gmail.com> <1314038973.3777.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:53815 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183Ab1HWAls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 20:41:48 -0400
Received: by yxj19 with SMTP id 19so3920332yxj.19
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 17:41:47 -0700 (PDT)
In-Reply-To: <1314038973.3777.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2011 01:49 PM, Eric Dumazet wrote:
> Le lundi 22 ao=C3=BBt 2011 =C3=A0 13:05 -0500, Gabriel Beddingfield a=
 =C3=A9crit :
>> On Mon, Aug 22, 2011 at 12:19 PM, Daniel Baluta<daniel.baluta@gmail.=
com>  wrote:
>>>>> It appears to me that the ACK is off-by-one (should have been 276=
76).
>>>>> The server replies again with retransmissions.  This is with seve=
ral
>>>>> kernel versions on local machines, ranging from 2.6.31 to 2.6.38.
>>>
>>>> Not a bug if frame carried a FIN
>>
>> The server packet had the FIN bit set.
>>
>
> then its fine.

Thank you!


>> I clipped the conversation to the vicinity of the problem.
>
> This sounds as a TSO bug, maybe driver/NIC related
>
> What is the NIC/driver used on your server ?

New news:  If I remove my router (Linksys WRTU54G-TM), the problem goes=
=20
away.

Thank you guys for your helpful insights. :-)

-gabriel
