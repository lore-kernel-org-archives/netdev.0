From: "J. M." <snortwiz@hotmail.com>
Subject: Re: OSDL Bugzilla #2399: A user can remotely route a packet through eth0 on a Li
Date: Thu, 13 May 2004 12:20:34 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BAY15-F5TPEFoxcC3U000054055@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com, dlstevens@us.ibm.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

That's exactly what's happening - a service bound to an interface is=20
receiving traffic via a different interface.  That could pose security ri=
sks=20
on a dual-homed machine (such as the device I pen-tested and discovered t=
his=20
flaw upon).

-Jared


>From: Nivedita Singhvi <niv@us.ibm.com>
>To: David Stevens <dlstevens@us.ibm.com>
>CC: netdev@oss.sgi.com, snortwiz@hotmail.com
>Subject: Re: OSDL Bugzilla #2399: A user can remotely route a packet=20
>through eth0 on a Linux machine
>Date: Tue, 11 May 2004 12:15:18 -0700
>MIME-Version: 1.0
>Received: from e32.co.us.ibm.com ([32.97.110.130]) by mc1-f18.hotmail.co=
m=20
>with Microsoft SMTPSVC(5.0.2195.6824); Tue, 11 May 2004 12:17:37 -0700
>Received: from westrelay03.boulder.ibm.com (westrelay03.boulder.ibm.com=20
>[9.17.195.12])by e32.co.us.ibm.com (8.12.10/8.12.2) with ESMTP id=20
>i4BJGFBM740870;Tue, 11 May 2004 15:16:15 -0400
>Received: from us.ibm.com ([9.17.193.83])by westrelay03.boulder.ibm.com=20
>(8.12.10/NCO/VER6.6) with ESMTP id i4BJGExf487372;Tue, 11 May 2004 13:16=
:15=20
>-0600
>X-Message-Info: JGTYoYF78jGRp3Vwe57C6WslWKHyO49+
>Message-ID: <40A12646.7080605@us.ibm.com>
>User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.2.1)=20
>Gecko/20030225
>X-Accept-Language: en-us, en
>References:=20
><OF94DCEE79.E30FBAF0-ON88256E91.0067773D-88256E91.0067C495@us.ibm.com>
>In-Reply-To:=20
><OF94DCEE79.E30FBAF0-ON88256E91.0067773D-88256E91.0067C495@us.ibm.com>
>Return-Path: niv@us.ibm.com
>X-OriginalArrivalTime: 11 May 2004 19:17:40.0399 (UTC)=20
>FILETIME=3D[A0AF03F0:01C4378C]
>
>David Stevens wrote:
>>Routing is something done between different hosts. Hosts normally
>>will accept packets for any local  address, regardless of
>>which interface it was received on.
>>
>>That's not a bug; that's how almost everything works.
>
>I think the only issue here is if an application that
>binds to an interface should see packets coming in
>from another - if that is what is happening here?.
>
>thanks,
>Nivedita
>
>
>

_________________________________________________________________
MSN Toolbar provides one-click access to Hotmail from any Web page =96 FR=
EE=20
download! http://toolbar.msn.com/go/onm00200413ave/direct/01/
