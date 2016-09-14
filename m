From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [net v1] fib_rules: interface group matching
Date: Wed, 14 Sep 2016 18:01:10 +0200
Message-ID: <8760pypj21.fsf@zoro.exoscale.ch>
References: <20160914124025.13417-1-vincent@bernat.im>
        <9540c014-78c5-9f9c-16d7-75a564f6c018@cumulusnetworks.com>
        <87h99ipnhu.fsf@zoro.exoscale.ch>
        <e8df55df-c22f-19a3-fabc-5fb592433706@cumulusnetworks.com>
        <87a8fapl7l.fsf@zoro.exoscale.ch>
        <c4f00f4e-aad3-f3d4-3c7c-8fe39c8f1720@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Wilson Kok <wkok@cumulusnetworks.com>, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:58118 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761966AbcINQBP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 12:01:15 -0400
In-Reply-To: <c4f00f4e-aad3-f3d4-3c7c-8fe39c8f1720@cumulusnetworks.com> (David
        Ahern's message of "Wed, 14 Sep 2016 09:25:49 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 14 septembre 2016 17:25 CEST, David Ahern <dsa@cumulusnetworks.c=
om>=C2=A0:

>> I could just give more time to VRF. I also had some concerns over
>> performance with the way Netfilter integration is done, but I understand
>> that I could just stay away from POSTROUTING rules which is the only
>> hook executed twice?

> With the changes that were committed this past weekend, the VRF code
> is now setup where I can set a flag on a per VRF basis to disable the
> extra rx and tx processing - ie., no network taps, no netfilter, no
> qdisc, etc. Drops the overhead of VRF to ~3% maybe a bit less. I need
> to think about the user api a bit more and formalize the patch. Given
> my other commitments that probably won't happen until mid-October. But
> in terms of a building block, the overhead of VRF is continuing to
> drop.

Fine by me. We can drop my patch.

Thanks!
--=20
Program defensively.
            - The Elements of Programming Style (Kernighan & Plauger)
