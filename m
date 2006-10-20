From: =?iso-8859-2?B?TWljaGFsIFL5vmnoa2E=?= <michal.ruzicka@comstar.cz>
Subject: Re: AF_KEY extended xfrm_state selector handling
Date: Fri, 20 Oct 2006 10:56:13 +0200
Message-ID: <00b501c6f425$a0325be0$2303a8c0@mruzicka>
References: <200610191626.k9JGQ7x4014606@gateplz.comstar.cz> <1161305972.5034.58.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-2";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateplz-adsl.comstar.cz ([193.179.24.196]:60893 "EHLO
	gateplz.comstar.cz") by vger.kernel.org with ESMTP id S2992585AbWJTI6N
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 04:58:13 -0400
To: <hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>
> BTW, why not use xfrm instead? Then you dont have to worry about racoon.

What do you mean by this?
- Do you suggest that there is another IKE implemetation for Linux 2.6 IPSec 
stack which uses netlink socket (XFRM) for kernel communication? If so, 
would you please point me to it?
Or
- Do you mean to make racoon use the netlink socket (XFRM) instead of PF_KEY 
for the kernel communication? (Well I'm not brave enough to tackle that.)
Or
- Do you mean something completely else?

> Unless you care about running this in some other OS (I suspect these
> OSes probably have made use of SADB_EXT_ADDRESS_PROXY so that may be a
> futile effort in any case).

I can see this might be problem, but a conditional compilation of the 
relevant bits of racoon should be enough to cope with that.

>
>
> cheers,
> jamal
>
> PS:- Nothing stands out for me in your patch, so i have no comment; i


OK, could you please apply it then?

> wasnt sure if the concept of tcp/udp port meant much to the concept of a
> security association

It is crucial for the multiple clients behind the same NAT scenario.

>
>

Regards Michal 

