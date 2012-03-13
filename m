From: Diego Woitasen <diego@woitasen.com.ar>
Subject: Re: ip route show shows the routes in the inverse order?
Date: Tue, 13 Mar 2012 11:26:36 -0300
Message-ID: <CAA7UhcmMYa+N4VUFjfM_qjCdhy3zAE0C8eN+Z0nsACNZeJ4RKA@mail.gmail.com>
References: <CAA7Uhc=xFxiAc9ZL0KHQJ1Opr0m=Do_OuLmL7WWd7PU4JuUNnQ@mail.gmail.com>
	<20120312193204.5be5b4b8@nehalam.linuxnetplumber.net>
	<20120313021529.97514922.billfink@mindspring.com>
	<20120312.235234.73408595516828250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: billfink@mindspring.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:41519 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754747Ab2CMO0i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 10:26:38 -0400
Received: by lbbgm6 with SMTP id gm6so255761lbb.19
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 07:26:36 -0700 (PDT)
In-Reply-To: <20120312.235234.73408595516828250.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 13, 2012 at 3:52 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Bill Fink <billfink@mindspring.com>
> Date: Tue, 13 Mar 2012 02:15:29 -0400
>
>> Some scripts may depend on this plus its much more efficent that way
>> if trying to find a matching route since you can quit on the first
>> match instead of having to scan the entire routing table.
>
> No script should be doing stuff like this, let the tool do it for you
> via "ip route get ADDR"
>
> There is absolutely no argument for routes to be listed in one order
> or another, and anything depending upon order is extremely fragile
> and needs to be fixed up anyways.

I don't aggree at this point. First, it was the behavior for years,
like a "de facto" standard. Second, there a "natural ordering"  for
routes. More specific match first, so it makes sense for them to be in
the first place.

>
> If you're trying to match something, do a real lookup, a longest
> prefix match lookup. =A0It's the only thing that's going to be correc=
t
> all the time, no matter what.



--=20
Diego Woitasen
