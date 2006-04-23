From: Avi Kivity <avi@argo.co.il>
Subject: Re: Van Jacobson's net channels and real-time
Date: Sun, 23 Apr 2006 12:23:16 +0300
Message-ID: <444B4784.8040803@argo.co.il>
References: <Pine.LNX.4.44L0.0604201819040.19330-100000@lifa01.phys.au.dk> <200604211852.47335.netdev@axxeo.de> <20060422114846.GA6629@wohnheim.fh-wedel.de> <200604221529.59899.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>,
	Ingo Oeser <netdev@axxeo.de>,
	"David S. Miller" <davem@davemloft.net>, simlo@phys.au.dk,
	linux-kernel@vger.kernel.org, mingo@elte.hu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw5.argo.co.il ([194.90.79.130]:26636 "EHLO argo2k.argo.co.il")
	by vger.kernel.org with ESMTP id S1750987AbWDWJXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2006 05:23:22 -0400
To: Ingo Oeser <ioe-lkml@rameria.de>
In-Reply-To: <200604221529.59899.ioe-lkml@rameria.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser wrote:
> Hi J=F6rn,
>
> On Saturday, 22. April 2006 13:48, J=F6rn Engel wrote:
>  =20
>> Unless I completely misunderstand something, one of the main points =
of
>> the netchannels if to have *zero* fields written to by both producer
>> and consumer.=20
>>    =20
>
> Hmm, for me the main point was to keep the complete processing
> of a single packet within one CPU/Core where this is a non-issue.
>  =20
But the interrupt for a packet can be received by cpu 0 whereas the res=
t=20
of processing proceeds on cpu 1; so it still helps to keep the producer=
=20
index and consumer index on separate cachelines.

--=20
error compiling committee.c: too many arguments to function

