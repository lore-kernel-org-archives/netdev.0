From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] net: release dst entry in dev_queue_xmit()
Date: Wed, 25 Mar 2009 22:12:02 +0100
Message-ID: <20090325211202.GC2928@ami.dom.local>
References: <49C380A6.4000904@cosmosbay.com> <20090324.234354.43714160.davem@davemloft.net> <49C9D99A.2040900@cosmosbay.com> <20090325.001720.238121238.davem@davemloft.net> <49CA7658.4010400@gmail.com> <49CA7AD7.8040401@cosmosbay.com> <20090325191850.GA2928@ami.dom.local> <49CA8895.8020105@cosmosbay.com> <20090325195424.GB2928@ami.dom.local> <49CA93F5.0@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.187]:10823 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830AbZCYVNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 17:13:41 -0400
Received: by ti-out-0910.google.com with SMTP id i7so121220tid.23
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 14:13:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <49CA93F5.0@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2009 at 09:28:37PM +0100, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
>=20
> > I guess you've considered the loopback too...
> >=20
>=20
> I had for the first patch (carefuly avoiding loopback being not respo=
nsive) :
> I was releasing dst only if enqueue() was called.
>=20
> You are right, loopback doesnt work anymore with last patch,
> and I have no idea why...
>=20
> Do you know why ?

Hmm.. isn't this test for dst =3D=3D NULL in ip_rcv_finish expected to =
be
negative for loopback source?

Jarek P.
