From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [net v1] fib_rules: interface group matching
Date: Wed, 14 Sep 2016 16:25:17 +0200
Message-ID: <87h99ipnhu.fsf@zoro.exoscale.ch>
References: <20160914124025.13417-1-vincent@bernat.im>
        <9540c014-78c5-9f9c-16d7-75a564f6c018@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Wilson Kok <wkok@cumulusnetworks.com>, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:57670 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1763868AbcINOZW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 10:25:22 -0400
In-Reply-To: <9540c014-78c5-9f9c-16d7-75a564f6c018@cumulusnetworks.com> (David
        Ahern's message of "Wed, 14 Sep 2016 08:15:21 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 14 septembre 2016 16:15 CEST, David Ahern <dsa@cumulusnetworks.c=
om>=C2=A0:

>> When a user wants to assign a routing table to a group of incoming
>> interfaces, the current solutions are:
>>=20
>>  - one IP rule for each interface (scalability problems)
>>  - use of fwmark and devgroup matcher (don't work with internal route
>>    lookups, used for example by RPF)
>>  - use of VRF devices (more complex)
>
> Why do you believe that? A VRF is a formalized grouping of interfaces
> that includes an API for locally generated traffic to specify which
> VRF/group to use. And, with the l3mdev rule you only need 1 rule for
> all VRFs regardless of the number which is the best solution to the
> scalability problem of adding rules per device/group/VRF.
>
> What use case are trying to solve?

Local processes have to be made aware of the VRF by binding to the
pseudo-device. Some processes may be tricked by LD_PRELOAD but some
won't (like stuff written in Go). Maybe I should just find a better way
to bind a process to a VRF without its cooperation.
--=20
Instrument your programs.  Measure before making "efficiency" changes.
            - The Elements of Programming Style (Kernighan & Plauger)
