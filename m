From: Atis Elsts <atis.elsts@gmail.com>
Subject: Re: Notifier chains bug ?
Date: Tue, 2 Mar 2010 17:57:02 +0200
Message-ID: <7f9bf5711003020757m505cad3fvac0b4ac006d1e8d7@mail.gmail.com>
References: <4B8C56F0.5090700@gmail.com>
	 <2375c9f91003011924k43f03649y5b4df405d6247a79@mail.gmail.com>
	 <5e9821061003012150y15e543cdkf6f23c3a7a47e4a3@mail.gmail.com>
	 <20100302153651.GC4014@hack>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Oleg Kutkov <elenbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:53648 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753499Ab0CBP5F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 10:57:05 -0500
Received: by ewy20 with SMTP id 20so238474ewy.21
        for <netdev@vger.kernel.org>; Tue, 02 Mar 2010 07:57:02 -0800 (PST)
In-Reply-To: <20100302153651.GC4014@hack>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm no expert, but IMHO for handling IP address changes you should use
function register_inetaddr_notifier() to register you callback and
then wait for NETDEV_UP and NETDEV_DOWN events.

On Tue, Mar 2, 2010 at 5:42 PM, Am=E9rico Wang <xiyou.wangcong@gmail.co=
m> wrote:
> On Tue, Mar 02, 2010 at 07:50:01AM +0200, Oleg Kutkov wrote:
>>2010/3/2 Am=E9rico Wang <xiyou.wangcong@gmail.com>:
>>> On Tue, Mar 2, 2010 at 8:08 AM, Oleg Kutkov <elenbert@gmail.com> wr=
ote:
>>>> Hello.
>>>> I try to used notifier chains for monitoring network devices event=
s.
>>>> All works perfectly when just i'm connecting/disconnecting network=
 cable or
>>>> up/down interface via ifconfig.
>>>> But when i try to change interface address - nothing happens. Noti=
fier is
>>>> don't send any events :(
>>>
>>> I think you mean IP address? No, NETDEV_CHANGEADDR is for hardware
>>> address, not for IP address.
>>>
>>> If you were changing mac address, you will receive NETDEV_CHANGEADD=
R.
>>>
>>
>>Thank for quick answer.
>>Yes, i mean IP address. And what about NETDEV_CHANGE ?
>
> It is for rtnetlink state transition.
>
>>Is there possible for monitoring IP address/netmask changing ?
>>
>
> AFAIK, no.
>
> Cc'ing netdev experts...
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
~Atis
