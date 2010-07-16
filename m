From: Chetan Loke <chetanloke@gmail.com>
Subject: Re: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index>
	mapping
Date: Fri, 16 Jul 2010 15:35:48 -0400
Message-ID: <AANLkTilhSSh1kE5ZfqVDbBJJWdP3hDcXRffpQwdyMQua@mail.gmail.com>
References: <D3F292ADF945FB49B35E96C94C2061B90C55C202@nsmail.netscout.com>
	<20100716113113.1e2b51c7@nehalam>
	<AANLkTin3V7LtmhDAOktNF1UITM86sJwButxCQ3vo31lv@mail.gmail.com>
	<20100716.123306.232886890.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, Chetan.Loke@netscout.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:33194 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865Ab0GPTft convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 15:35:49 -0400
Received: by vws5 with SMTP id 5so2912994vws.19
        for <netdev@vger.kernel.org>; Fri, 16 Jul 2010 12:35:48 -0700 (PDT)
In-Reply-To: <20100716.123306.232886890.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 16, 2010 at 3:33 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Chetan Loke <chetanloke@gmail.com>
> Date: Fri, 16 Jul 2010 15:29:06 -0400
>
>> On Fri, Jul 16, 2010 at 2:31 PM, Stephen Hemminger
>> <shemminger@vyatta.com> wrote:
>>> Simple way:
>>> =C2=A0 Use SIOCGIFCONF to get list of interfaces
>>> =C2=A0 Use SIOCGIFHWADDR to read device addresss
>>>
>> And interfaces that don't have IP's?
>
> There is no requirement that an interface have configured IP addresse=
s
> in order to use those ioctl()'s.
>
> You simply create an arbitrary socket, and use the resulting 'fd' to
> run the ioctl's mentioned to fetch information about any and all
> interfaces which exist in the system.
>

Yes, I opened a socket and then sent the IFCONF ioctl.What I meant was
that interfaces that didn't have an IP weren't returned.
