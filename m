From: Mallika Gautam <mallika.gautam@gmail.com>
Subject: Re: Policy routing + route "via" gives a strange behavior
Date: Wed, 21 Oct 2009 09:47:08 +0100
Message-ID: <9041a1390910210147v57b04afg5c0ac320b87eafd2@mail.gmail.com>
References: <20091020132820.GA3159@gg.studio.tixteam.net> <200910201948.39778.atis@mikrotik.com>
	<20091020172334.GA6404@gg.studio.tixteam.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Atis Elsts <atis@mikrotik.com>, netdev@vger.kernel.org
To: Guido Trotter <ultrotter@quaqua.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:44761 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210AbZJUIrY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 04:47:24 -0400
Received: by ewy3 with SMTP id 3so5770001ewy.17
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 01:47:28 -0700 (PDT)
In-Reply-To: <20091020172334.GA6404@gg.studio.tixteam.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>> Anyway, you can achieve what you wish by using the "onlink" option, =
e.g.:
>> =A0 ip route add table 100 default dev eth1 via 192.168.5.254 onlink
>

Hi,
I am facing exactly the same issue and have to flush the main table
once the routes in the table get added. This is really nasty as I need
to this from a kernel module every time an interface is shutdown and
again brought up.

"onlink" doesn't seem to work as it "sees" the destination IP address
"onlink" instead of resolving it via the gateway. E.g. if I want to
ping 139.85.111.12 via eth1, it tries to send ARP request for
139.85.111.12  and not 192.168.5.254. So it doesn' work.

I would really link to see this behaviour fixed as the workarounds are
equally painful.

Regards
Mallika
