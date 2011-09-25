From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Sun, 25 Sep 2011 22:10:13 +0200
Message-ID: <4E7F8AA5.1060709@gmail.com>
References: <20110902172247.396753508@vyatta.com> <4E614CF7.7030700@gmail.com> <20110902151100.327af0bf@nehalam.ftrdhcpuser.net> <4E6272BC.4020707@gmail.com> <20110903211438.2a43d2f2@nehalam.ftrdhcpuser.net> <4E632A2E.5040805@gmail.com> <20110904093634.685d7c56@nehalam.ftrdhcpuser.net> <4E65046E.1020005@gmail.com> <20110905105735.1b912715@nehalam.ftrdhcpuser.net> <4E65C31F.1010809@gmail.com> <20110925091606.GE32712@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37913 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146Ab1IYUKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2011 16:10:05 -0400
Received: by wyg34 with SMTP id 34so5346330wyg.19
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2011 13:10:04 -0700 (PDT)
In-Reply-To: <20110925091606.GE32712@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/09/2011 11:16, Marc Haber a =C3=A9crit :
> On Tue, Sep 06, 2011 at 08:52:15AM +0200, Nicolas de Peslo=C3=BCan wr=
ote:
>> I really support the idea to keep the current behavior (assert
>> carrier on br0 when at least one port have carrier) and to fix the
>> applications to wait for the IPv6 address to be checked (DAD)
>> instead of dying on bind() failure.
>
> A really brilliant idea. Break things and then expect hundreds of app=
s
> or millions of installations to adapt.

Well... Considering the noise you made recently about the new bridge be=
havior, I'm sure we all=20
understand this is a problem for you.

We try and find a reasonable solution between two somewhat incompatible=
 expectations and this is not=20
easy. If you have had a real reading of my proposal, you would have not=
iced that I really tried to=20
find a solution that would be acceptable for both situations. Stephen, =
which is far more experienced=20
than me on this topic explained that my proposal was (and still is) not=
 applicable.

Instead of annoying us with comments like "brilliant idea" or "nice ide=
a", feel free to propose=20
something that would contribute to the solution.

	Nicolas.
