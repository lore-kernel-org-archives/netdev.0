From: nisse@southpole.se (Niels =?utf-8?Q?M=C3=B6ller?=)
Subject: Re: What's the right way to use a *large* number of source addresses?
Date: Mon, 26 May 2014 08:39:34 +0200
Message-ID: <6zsinxt55l.fsf@southpole.se>
References: <6zlhtsvnqp.fsf@southpole.se>
	<CAHA+R7OkR_M9T51Y3zQa2QG3Rq1edJjT0SoMoaoD2tkyefnm4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:50349 "EHLO mail.southpole.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751458AbaEZGjo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 02:39:44 -0400
In-Reply-To: <CAHA+R7OkR_M9T51Y3zQa2QG3Rq1edJjT0SoMoaoD2tkyefnm4A@mail.gmail.com>
	(Cong Wang's message of "Fri, 23 May 2014 15:39:55 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <cwang@twopensource.com> writes:

> On Fri, May 23, 2014 at 2:38 AM, Niels M=C3=B6ller <nisse@southpole.s=
e> wrote:
>>
>> So now I'm trying to figure out what's the Right Way to enable traff=
ic
>> generations with a large number of source addresses, to possibly ret=
ire
>> the proprietary kernel module. I see a couple of different approache=
s:
>
> Isn't pktgen is what you are looking for?

No, I'd like to have a user-space application using a plain tcp socket
as the endpoint.

In my experience, pktgen is useful if you want to test the limits of ra=
w
packet performance of network cards and drivers, or generate load on
networking equipment. But not for generating load on a real application=
,
where the data needs to follow some higher level protocol.

Regards,
/Niels
