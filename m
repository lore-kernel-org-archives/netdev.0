From: "Baron, Jason" <jbaron@akamai.com>
Subject: Re: [PATCH v2 net-next 0/2] bnx2x: page allocation failure
Date: Mon, 3 Oct 2016 20:24:32 +0000
Message-ID: <C6EA6A20-ECFC-43B5-B720-DC14CD212E7A@akamai.com>
References: <cover.1474577624.git.jbaron@akamai.com>
 <20160926.094606.142250516441125849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>,
        "Yuval.Mintz@qlogic.com" <Yuval.Mintz@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:24664 "EHLO
        prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751625AbcJCUYe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 16:24:34 -0400
In-Reply-To: <20160926.094606.142250516441125849.davem@davemloft.net>
Content-Language: en-US
Content-ID: <F3BBADD259AF65489E473EF94482B59C@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On Sep 26, 2016, at 9:46 AM, David Miller <davem@davemloft.net> wrote:
>=20
> From: Jason Baron <jbaron@akamai.com>
> Date: Thu, 22 Sep 2016 17:12:24 -0400
>=20
>> While configuring ~500 multicast addrs, we ran into high order
>> page allocation failures. They don't need to be high order, and
>> thus I'm proposing to split them into at most PAGE_SIZE allocations.
>>=20
>> Below is a sample failure.
> ...
>> v2:
>> -make use of list_next_entry()
>> -only use PAGE_SIZE allocations
>=20
> Series applied, thanks Jason.

Hi David,

I have a small correction for 2/2. Can I post a v3? Or should I just send t=
he incremental at this point?

Thanks,

-Jason=
