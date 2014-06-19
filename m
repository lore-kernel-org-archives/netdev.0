From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH V3 net-next] LISP: Locator/Identifier Separation Protocol
Date: Thu, 19 Jun 2014 10:29:20 -0700
Message-ID: <CA+mtBx9_BXJqEdh-5xKZhhNMgtHXtqaKDm5VGvEjUk+ubb1=fQ@mail.gmail.com>
References: <86BFD474-6614-418E-B4B3-C725848FE196@logicalelegance.com>
	<CA+mtBx-aNF9-H+N_VmHqFGdVgGAdR5xer8F19wAvSKmUZpGy4Q@mail.gmail.com>
	<6A1822EF-41D2-49AC-AA94-227458773FF8@logicalelegance.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Vina Ermagan (vermagan)" <vermagan@cisco.com>,
	"Lorand Jakab -X (lojakab - M SQUARED CONSULTING INC. at Cisco)"
	<lojakab@cisco.com>
To: Christopher White <chris@logicalelegance.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36544 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933382AbaFSR3V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 13:29:21 -0400
Received: by mail-ig0-f179.google.com with SMTP id r2so2223332igi.0
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2014 10:29:20 -0700 (PDT)
In-Reply-To: <6A1822EF-41D2-49AC-AA94-227458773FF8@logicalelegance.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I was actually thinking this function could be even more general. Th=
e
>> L2TP_ENCAPTYPE_UDP case in l2tp_tunnel_sock_create looks like
>> something we might be able to abstract out into a separate function-=
-
>> it would include IPv6 support and the possibility of binding to othe=
r
>> than INADDR_ANY and connected sockets. l2tp_tunnel_cfg could be the
>> basis of udp_port_cfg which contains addresses, ports, and sockopts
>> like sk_no_check_tx=E2=80=A6
>>
>
> So I=E2=80=99m happy to do this, but I would like to do it in a separ=
ate submission.
> For one thing, I am not super familiar with that code and I=E2=80=99m=
 a bit nervous
> about making substantive changes, thus it may take me some time.
> As it is orthogonal to the LISP submission, would it be possible to d=
o this
> separately and have LISP move forward?
>
Okay, I'll post an implementation of the general function once
net-next opens up.

> Thanks!
> -Chris
>
