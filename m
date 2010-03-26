From: Richard Hartmann <richih.mailinglist@gmail.com>
Subject: Re: [Patch] fix packet loss and massive ping spikes with PPP
	multi-link
Date: Fri, 26 Mar 2010 17:39:27 +0100
Message-ID: <v2v2d460de71003260939w4877df7em9e3084a315b0962f@mail.gmail.com>
References: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>
	 <20100326160226.0159ac3b@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f221.google.com ([209.85.219.221]:43475 "EHLO
	mail-ew0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217Ab0CZQj3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 12:39:29 -0400
In-Reply-To: <20100326160226.0159ac3b@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 26, 2010 at 17:02, Alan Cox <alan@lxorguk.ukuu.org.uk> wrot=
e:

> You should be able to manage that I'm sure:

Hopefully. We will see :)


> MODULE_PARM_DESC(ml_expode, "Set this to zero to disabling multilink =
\
> =C2=A0 =C2=A0 =C2=A0 =C2=A0fragmentation when talking to cisco device=
s");

To be exact, this is not a Linux vs. Cisco issue, but a Linux vs. world
issue.

At least the last-level support of Telefonica and QSC was definite and
adamant about not enabling fragmentation on _any_ PPP multi-link, ever.

Also, I am not sure if it would not be better to default to no
fragmentation and enable it optionally. I am aware that changing defaul=
t
behaviour is always a bit of a problem but to the best of my knowledge
enabling fragmentation is a bug in any and all real-world applications.


Richard
