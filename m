From: "J. M." <snortwiz@hotmail.com>
Subject: Re: OSDL Bugzilla #2399: A user can remotely route a packet through eth0 on a Li
Date: Thu, 13 May 2004 12:18:25 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BAY15-F30Ic7C9R52VX000327b2@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com, niv@us.ibm.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It seems that design is flawed from a security perspective.  Granted=20
dual-homed machines are not the ideal model for security, but I still=20
shouldn't be able to access an interface on a different network just beca=
use=20
it's connected to the same physical box as an interface I can reach.

-Jared


>From: David Stevens <dlstevens@us.ibm.com>
>To: niv@us.ibm.com
>CC: netdev@oss.sgi.com, snortwiz@hotmail.com
>Subject: Re: OSDL Bugzilla #2399: A user can remotely route a packet=20
>through eth0 on a Linux machine
>Date: Tue, 11 May 2004 12:53:46 -0600
>MIME-Version: 1.0
>Received: from e33.co.us.ibm.com ([32.97.110.131]) by mc1-f25.hotmail.co=
m=20
>with Microsoft SMTPSVC(5.0.2195.6824); Tue, 11 May 2004 11:55:13 -0700
>Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com=20
>[9.17.195.11])by e33.co.us.ibm.com (8.12.10/8.12.2) with ESMTP id=20
>i4BIro87448576;Tue, 11 May 2004 14:53:50 -0400
>Received: from d03nm121.boulder.ibm.com (d03av02.boulder.ibm.com=20
>[9.17.195.168])by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with=20
>ESMTP id i4BIrnMV366996;Tue, 11 May 2004 12:53:49 -0600
>X-Message-Info: JGTYoYF78jEQFFy/ZNDuigEHjOC6Zg85
>In-Reply-To: <40A11644.7090402@us.ibm.com>
>X-Mailer: Lotus Notes Release 6.0.2CF1 June 9, 2003
>Message-ID:=20
><OF94DCEE79.E30FBAF0-ON88256E91.0067773D-88256E91.0067C495@us.ibm.com>
>X-MIMETrack: Serialize by Router on D03NM121/03/M/IBM(Release 6.0.2CF2HF=
168=20
>| December 5, 2003) at 05/11/2004 12:53:49,Serialize complete at 05/11/2=
004=20
>12:53:49
>Return-Path: dlstevens@us.ibm.com
>X-OriginalArrivalTime: 11 May 2004 18:55:16.0369 (UTC)=20
>FILETIME=3D[7F945010:01C43789]
>
>Routing is something done between different hosts. Hosts normally
>will accept packets for any local  address, regardless of
>which interface it was received on.
>
>That's not a bug; that's how almost everything works.
>
>                                 +-DLS
>

_________________________________________________________________
FREE pop-up blocking with the new MSN Toolbar =96 get it now!=20
http://toolbar.msn.com/go/onm00200415ave/direct/01/
