From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next 1/3] cxgb4: Add support for loopback between VI of same port
Date: Fri, 22 May 2015 16:46:57 -0700
Message-ID: <02F05AD8-11B0-4CC9-955C-2D0FACC8522C@chelsio.com>
References: <4985EFDD773FCB459EF7915D2A3621ADBD9FE5@nice.asicdesigners.com> <20150521.153029.774385014187583893.davem@davemloft.net> <4985EFDD773FCB459EF7915D2A3621ADBDA809@nice.asicdesigners.com> <20150522.140100.204940697669252730.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
	nirranjan@chelsio.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30054 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757376AbbEVXrA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 19:47:00 -0400
In-Reply-To: <20150522.140100.204940697669252730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Okay, really: I=92m not arguing for module parameters.  I=92m agreein=
g with you 100%.
I=92m not trying to be snarky or back you into admitting that there are=
 some times
when a module parameter is needed.  I=92m not being sneaky, etc.  I=92m=
 really just
asking a mechanism question.  It is, on the other hand, quite likely th=
at I=92m
being dumb.  I=92ll absolutely grant you that.

  So let me turn this around and ask:

    What command would you envision that I use in order to tell a drive=
r
    to use a different TX routine for an interface?

        ethtool =97tx-routine eth{n} loopback

    Or?

 Sorry for being so dense.  We really are trying to live within the rul=
es but
we=92re struggling to figure out what patch we should submit.

Casey

> On May 22, 2015, at 11:01 AM, David Miller <davem@davemloft.net> wrot=
e:
>=20
> From: Casey Leedom <leedom@chelsio.com>
> Date: Fri, 22 May 2015 16:49:03 +0000
>=20
>>  Oh I definitely understand that and agree.  Unfortunately I've
>> inherited a driver architecture that makes that ... "difficult"
>> for many operations ...  And I have an internal bug filed
>> against me to fix those particular issues.
>>=20
>>  However, that doesn't answer at least one of my questions
>> which was how do I pass information into the driver _before_
>> it does the device probe?
>=20
> I did answer the question, I said that if you fix the real actual
> core problem then you won't have this need to begin with.
>=20
> I thought I made that perfectly clear.
>=20
> I really am not going to entertain arguments of the form "it's
> too hard to implement this correctly so I'm going to try
> and slam a module parameter into the driver to fix things".
>=20
