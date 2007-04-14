From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: TCP connection stops after high load.
Date: Sat, 14 Apr 2007 07:31:35 +0200
Message-ID: <46206737.8000307@cosmosbay.com>
References: <E1HcZlg-0006Bi-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: danielschaffrath@mac.com, greearb@candelatech.com,
	andi@firstfloor.org, netdev@vger.kernel.org, bcrl@kvack.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:45388 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161095AbXDNFcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2007 01:32:18 -0400
In-Reply-To: <E1HcZlg-0006Bi-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu a =E9crit :
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>> dev_queue_xmit_nit() is called before attempting to send packet to d=
evice.
>>
>> If device could not accept the packet (hard_start_xmit() returns an =
error), packet is requeued and retried later.
>> each retry means call ev_queue_xmit_nit() again, so tcpdump/sniffers=
 can 'see' packet transmited several times.=20
>=20
> This should only happen with LLTX drivers.  In fact, LLTX drivers are
> really more trouble than they're worth.  They should all be rewritten
> to follow the model used in tg3.

When did tg3 model changed exactly ?

Because I remember having this 'problem' with tg3 devices not a long ti=
me ago...

