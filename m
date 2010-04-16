From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 09:42:05 -0400
Message-ID: <1271425325.4606.50.camel@bigi>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <o2v412e6f7f1004152302j1aca5edam9d53d01781ddbe9d@mail.gmail.com>
	 <1271399547.16881.3724.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f196.google.com ([209.85.221.196]:36918 "EHLO
	mail-qy0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757329Ab0DPNmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 09:42:07 -0400
Received: by qyk34 with SMTP id 34so3294585qyk.22
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 06:42:05 -0700 (PDT)
In-Reply-To: <1271399547.16881.3724.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-04-16 at 08:32 +0200, Eric Dumazet wrote:
> Le vendredi 16 avril 2010 =C3=A0 14:02 +0800, Changli Gao a =C3=A9cri=
t :
>=20
> > resched IPI, apparently. But it is async absolutely. and its IRQ
> > handler is lighter.
> >=20
>=20
> You still dont answer to the question, and your claims are not ground=
ed
> by hard facts, but by your interpretation of code.

My understanding of current scheduler is it does use IPIs to migrate
tasks around - so thats why things may be working for Changli. i.e
it is scheduler magic if you use kthreads. It is hard to say if this
would work better...

cheers,
jamal

