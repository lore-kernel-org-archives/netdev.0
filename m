From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Enable syn cookies by default
Date: Wed, 21 Oct 2009 09:25:06 +0200
Message-ID: <4ADEB752.50103@gmail.com>
References: <b2cc26e40910100601q7aed04acjcc9973ef06e6458f@mail.gmail.com>	 <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com> <b2cc26e40910210017v3885b18dre5021c8a920f30d7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Olaf van der Spek <olafvdspek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54478 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbZJUHZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 03:25:04 -0400
In-Reply-To: <b2cc26e40910210017v3885b18dre5021c8a920f30d7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olaf van der Spek a =C3=A9crit :
> On Thu, Oct 15, 2009 at 10:59 AM, Olaf van der Spek
> <olafvdspek@gmail.com> wrote:
>> On Sat, Oct 10, 2009 at 3:01 PM, Olaf van der Spek <olafvdspek@gmail=
=2Ecom> wrote:
>>> Hi,
>>>
>>> I'm forwarding Debian feature request #520668.
>>>
>>> Could syn cookies be enabled by default?
>>>
>>> AFAIK syn cookies only get send when the half-open TCP connection
>>> queue is full. So stuff like window scaling should work fine in nor=
mal
>>> situations.
>>>
>>> Speaking of which:
>>> When the half-open TCP connection queue is full and syn cookies are
>>> enabled, you get a message like "kernel: possible SYN flooding on p=
ort
>>> 2710. Sending cookies."
>>> However when syn cookies are disabled, you don't get any message (i=
n
>>> kern.log), although connections to your server are timing out.
>>> Could such a message be added?
>>> Maybe with a suggestion to increase the size of that queue or to
>>> enable syn cookies.
>>>
>>> Greetings,
>>>
>>> Olaf
>>>
>>> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D520668
>>> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D520667
>>> https://bugs.launchpad.net/ubuntu/+bug/57091
>>>
>> Somebody?
>=20
> Anybody?

This is a user selectable setting. What's wrong with /etc/sysctl.conf ?


