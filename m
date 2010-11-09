From: Luke Hutchison <luke.hutch@gmail.com>
Subject: Re: Networking hangs when too many parallel requests are made at once
Date: Tue, 9 Nov 2010 17:20:45 -0500
Message-ID: <AANLkTi=qgJcBUdhDpV8QdPPUO1o7QjZLUj07_C1B9Ygg@mail.gmail.com>
References: <AANLkTikuCj=saH34dyO6xnU-y8rWv63hJaqowZ0ACLzk@mail.gmail.com>
 <AANLkTinRo_ozWFCYYqanOh0YrTJ6+KadutG2j7T726dY@mail.gmail.com>
 <4CD99E20.4060307@candelatech.com> <AANLkTinz6C4s3wX7t6CsE2bzZ2adCoi0RAcqvpEFE2GV@mail.gmail.com>
 <4CD9B09B.8040906@candelatech.com> <AANLkTinu4=Ox_vA_yr7vbdbcqr4P7oS+zMX_yaXhK4E9@mail.gmail.com>
 <4CD9C7E2.6050909@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:64871 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497Ab0KIWV0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 17:21:26 -0500
Received: by gwj21 with SMTP id 21so4723034gwj.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 14:21:25 -0800 (PST)
In-Reply-To: <4CD9C7E2.6050909@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 9, 2010 at 5:14 PM, Ben Greear <greearb@candelatech.com> wr=
ote:
> Have you tried using a different DNS server (open-dns?), or maybe a c=
aching
> one one
> your local machine? =C2=A0Maybe some part of your network is throwing=
 away
> some of your DNS requests since you send so many at once?

I have tried Google's DNS as well as Comcast's, no difference in
effect.  Also this has been a problem when I've been in the US,
Portugal, Germany and China, so I have probably used a range of DNS
servers.  I have tried nscd (it's off by default) and it has the
expected behavior: if it resolves a name before re-opening the
browser, then that name can continue to be resolved after the network
gets flooded.  If I ask it to resolve a domain name after the network
is flooded, the request times out, and subsequently nscd says the
domain name doesn't exist, even after the network link has been
restored to normal.

Thanks,
Luke
