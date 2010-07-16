From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Subject: RE: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index> mapping
Date: Fri, 16 Jul 2010 16:49:05 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90C55C32A@nsmail.netscout.com>
References: <AANLkTinAiJJqhrro8Jlrb0WgHzDSCx_dtWXL5N9ZKUbd@mail.gmail.com><20100716.130445.149851386.davem@davemloft.net><AANLkTineSDEEKY-9ve2maSBmPWBxkW5XmqnHlLtIOClx@mail.gmail.com> <20100716.131835.124042396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <shemminger@vyatta.com>, <bhutchings@solarflare.com>,
	<netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og115.obsmtp.com ([64.18.1.35]:51208 "HELO
	exprod6og115.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754961Ab0GPUtJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 16:49:09 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100716.131835.124042396.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ooops... I got the 'CC' list this time



On Fri, Jul 16, 2010 at 4:33 PM, David Miller <davem@davemloft.net>
wrote:
> From: Chetan Loke <chetanloke@gmail.com>
> Date: Fri, 16 Jul 2010 16:24:16 -0400
>
>> Thanks for your time guys.
>
> You dropped everything from the CC: list, so nobody other
> than me saw this. :)
>
>

On Fri, Jul 16, 2010 at 4:24 PM, Chetan Loke <chetanloke@gmail.com>
wrote:
> On Fri, Jul 16, 2010 at 4:18 PM, David Miller <davem@davemloft.net>
wrote:
>> From: Chetan Loke <chetanloke@gmail.com>
>> Date: Fri, 16 Jul 2010 16:15:44 -0400
>>
>>> Ok, what if, i) ifindex == 0 in the call to SIOCGIFINDEX or ii) if
the
>>> ifindex is not found ? May be then in the else clause we could
search
>>> using the hw-addr before bailing out ;)? This way we can avoid
adding
>>> a new API. Still not a good idea?
>>
>> I'm really not going to consider this seriously, sorry.  I've
>> made my position pretty clear, and gave sufficient reasons for
>> it.
>>
>> Myself and others have also shown you several ways to fetch the
>> information you need, and of them netlink is probably the most
>> efficient, but the others work just as well.
>>
>> The new interface proposals are just not a good idea.
>>
>
> No problem Dave. I will patch our internal iso and add dev_getbyhwaddr
> in the else clause.
>
> Thanks for your time guys.
>
> regards
> Chetan Loke
>

