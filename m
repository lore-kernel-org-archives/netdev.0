From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 40k+ outbound connections and bind() problem
Date: Wed, 26 Jan 2011 14:26:49 +0100
Message-ID: <1296048409.2899.63.camel@edumazet-laptop>
References: <8cdb2dde69120a8668b31e2050916493@visp.net.lb>
	 <AANLkTikSvf8bNK2_eHg+cWQJLz-56_88mrf0ttJX3W=0@mail.gmail.com>
	 <9e62acde19ef75f3f77468cd81ed7ffd@visp.net.lb>
	 <AANLkTinDQ-n3Y2_8PtvdWSxkYV8Kvj8on3iEeHsBSFB-@mail.gmail.com>
	 <1296047834.2899.62.camel@edumazet-laptop>
	 <398df9351d5c9aec1ba69511d9dc6a70@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Baluta <daniel.baluta@gmail.com>, netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43164 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594Ab1AZN04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 08:26:56 -0500
Received: by wwa36 with SMTP id 36so951952wwa.1
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 05:26:54 -0800 (PST)
In-Reply-To: <398df9351d5c9aec1ba69511d9dc6a70@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 janvier 2011 =C3=A0 15:23 +0200, denys@visp.net.lb a =C3=
=A9crit :
> On Wed, 26 Jan 2011 14:17:14 +0100, Eric Dumazet wrote:
> > Le mercredi 26 janvier 2011 =C3=A0 15:00 +0200, Daniel Baluta a =C3=
=A9crit :
> >> Hi,
> >>
> >> > Latest stable, 2.6.37
> >>
> >> Please apply this patch [1] and see if it's still happening.
> >>
> >> thanks,
> >> Daniel
> >>
> >> [1] http://www.spinics.net/lists/netdev/msg152204.html
> >> -
> >
> > I dont think it'll help ;)
> >
> > Denys problem is if one source IP address is used, there is an=20
> > absolute
> > 64K limit to (IP, port) tuple
> >
> > Only thing you can do is to tune=20
> > /proc/sys/net/ipv4/ip_local_port_range
> > to get close to 64K limit
>  No, it is not one ip source.
>  As i mention before, i am binding each instance to different IP befo=
re=20
>  connect().
>  And when i am having issues and such errors, i am trying httping and=
=20
>  binding it to some unused ip, but still getting this error.

Ah OK, you definitely want to use REUSEADDR then.



