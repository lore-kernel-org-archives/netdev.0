From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Need a special way tune TCP IPv6->IPv4 fallback timeout
Date: Thu, 24 Mar 2011 10:24:01 -0700
Message-ID: <20110324102401.682f0e1e@nehalam>
References: <AANLkTikP7AFMnQ4BdnE2272zNupv_ysb3BDWTqy=9s34@mail.gmail.com>
	<20110324095702.6f6bade0@nehalam>
	<AANLkTinb_4N_S7LG8MjT0YTAjVSkEyViv+Y-_ZN2SemC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Guillaume Leclanche <guillaume@leclanche.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55363 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751381Ab1CXRYH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 13:24:07 -0400
In-Reply-To: <AANLkTinb_4N_S7LG8MjT0YTAjVSkEyViv+Y-_ZN2SemC@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Mar 2011 18:05:35 +0100
Guillaume Leclanche <guillaume@leclanche.net> wrote:

> 2011/3/24 Stephen Hemminger <shemminger@vyatta.com>:
> > The best way is to try both at the same time. This trick is known
> > as "Happy Eyeballs"
> >
> > =C2=A0http://tools.ietf.org/html/draft-wing-v6ops-happy-eyeballs-ip=
v6-01
>=20
> Happy eyeballs implementation would be royal, I thought my proposal
> would be easier to implement as a first step. I'm very likely to be
> wrong though :) Well, if anybody is working currently on Happy
> Eyeballs implementations in the TCP stack, it's great !

It is best handled in client. Not in the stack itself because
only client has DNS records to work with.
