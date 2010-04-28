From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] random SYN drops causing connect() delays
Date: Wed, 28 Apr 2010 07:52:46 +0200
Message-ID: <1272433966.2343.34.camel@edumazet-laptop>
References: <20100412080633.GA27418@bombadil.infradead.org>
	 <20100412083903.GA19763@bombadil.infradead.org>
	 <20100427.185602.221594952.davem@davemloft.net>
	 <20100428044443.GL19763@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:57982 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053Ab0D1Fww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 01:52:52 -0400
Received: by bwz19 with SMTP id 19so196182bwz.21
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 22:52:51 -0700 (PDT)
In-Reply-To: <20100428044443.GL19763@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 28 avril 2010 =C3=A0 00:44 -0400, Thomas Graf a =C3=A9crit =
:
> On Tue, Apr 27, 2010 at 06:56:02PM -0700, David Miller wrote:
> > I can't reproduce on my system even with sched_child_runs_first set=
 to '1'.
> >=20
> > Are you running identd or something like that which intercepts the =
connections
> > to port 22 before 'sshd' actually gets it?
>=20
> No, sshd is listening on the port directly.
>=20
> I am having more difficulties to reproduce the issue with the latest =
git tree. It
> still happens but I sometimes have to run the test several times to g=
et a single
> delayed connection attempt.

On machine/kernel reproducing the behavior, please send

grep . /proc/sys/net/ipv4/*



