From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: MPLS for Linux kernel
Date: Tue, 22 Nov 2011 09:52:07 +0100
Message-ID: <CAFdo_mXzqC_v5OkC6P012gFT_OmRO_yDTA0w96VhV-Lp3Hp7Fw@mail.gmail.com>
References: <CAFdo_mWE8wMB6QJt_DPi9Ou9OiayzV48URDq7KhKf+q8OfP+Gw@mail.gmail.com>
	<4ECA67C6.2080802@dti2.net>
	<20111121.132914.1611617296397809001.davem@davemloft.net>
	<4ECAA41C.9040007@dti2.net>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:53973 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755230Ab1KVIwM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 03:52:12 -0500
Received: from localhost (avs1.etf.rs [147.91.14.172])
	by mx1.etf.bg.ac.rs (Postfix) with ESMTP id AA41212011A
	for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 09:52:10 +0100 (CET)
Received: from mx2.etf.bg.ac.rs ([147.91.14.170])
	by localhost (avs1.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id z+CTvlrpgTdZ for <netdev@vger.kernel.org>;
	Tue, 22 Nov 2011 09:52:10 +0100 (CET)
Received: from mail-pz0-f42.google.com (mail-pz0-f42.google.com [209.85.210.42])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id AAD1E6013B
	for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 09:52:09 +0100 (CET)
Received: by pzk36 with SMTP id 36so16265421pzk.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 00:52:07 -0800 (PST)
In-Reply-To: <4ECAA41C.9040007@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What are the main reasons for You to think that mpls-linux is not
ready to go upstream?
As I said, I fixed a lot of bugs so code can be run with all the
kernel hacking options enabled, without causing panics and oopses.
Also fixed a lot of other things and added preprocessor if statements
where code is intertwined with normal kernel code, so I'm sure that it
want break existing kernel compilation if the kernel is compiled
without MPLS.
Why would it be so hard to implemented it in terms of packet scheduler?
BR
Igor

2011/11/21 Jorge Boncompte [DTI2] <jorge@dti2.net>:
> El 21/11/2011 19:29, David Miller escribi=F3:
>> From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
>> Date: Mon, 21 Nov 2011 16:01:26 +0100
>>
>>> =A0 =A0 =A0mpls-linux it is not ready to go upstream in my opinion.
>>
>> And can arguably be implemented in terms of openvswitch and packet s=
cheduler actions.
>
> =A0 =A0 =A0 =A0I guess so, I have not really looked much at the openv=
switch code. The MPLS
> code it is pretty self contained and in my opinion more tied to routi=
ng than to
> switching (*). I don't think it should be necessary an userspace daem=
on, like it
> seems necessary for openvswitch, just to bind a label to a route, the=
 same way
> that it is not necessary a daemon to support VLAN's currently. The la=
bel
> signaling protocols are already complicated :)
>
> =A0 =A0 =A0 =A0I work in this code, like a lot of people do, because =
I have a use for it. I
> would really like to see it upstreamed but if it does not fit upstrea=
m plans, it
> is not a problem, this code it is not that hard to maintain.
>
> =A0 =A0 =A0 =A0In any case critics/reviews/patches are most than welc=
ome.
>
> (*) The code that you implemented for 2.6.1 and that James R. Leu use=
d in this
> codebase it is even more tied together to routing.
>
>
