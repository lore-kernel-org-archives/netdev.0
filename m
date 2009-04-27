From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 00/13] OF device tree handling of PHY drivers
Date: Mon, 27 Apr 2009 07:07:07 -0600
Message-ID: <fa686aa40904270607k77c38efasee194a61bfa3de04@mail.gmail.com>
References: <20090425224458.32392.31296.stgit@localhost.localdomain>
	<20090427.025436.68188155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:65490 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639AbZD0NHW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 09:07:22 -0400
Received: by yx-out-2324.google.com with SMTP id 3so1353136yxj.1
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 06:07:22 -0700 (PDT)
In-Reply-To: <20090427.025436.68188155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2009 at 3:54 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Grant Likely <grant.likely@secretlab.ca>
> Date: Sat, 25 Apr 2009 16:52:34 -0600
>
>> This series adds common code for reading PHY connection data out of
>> the OpenFirmware device tree. =A0This simplifies the network drivers
>> which use the device tree and which currently implement their own
>> solutions for reading the PHY data out of the device tree directly.
>>
>> I would like to see this series, or at least the core changes (1-4)
>> plus the tested drivers (5-8 & 12, but #12 is a new driver and it
>> may need more review), go into -next for 2.6.31.
>>
>> Due to dependencies, I think it is easiest if all of them go in via =
the
>> same tree. =A0David, are you willing to merge them via yours? =A0Fou=
r of the
>> patches are outside of drivers/net (patches 1 and 4 touch drivers/of=
/,
>> and patches 9 & 10 touch arch/powerpc), but I personally have no iss=
ues
>> if those changes go through you. =A0I just need to double check with=
 BenH.
>
> I've applied all of these patches to net-next-2.6, thanks.
>
>> =A0 git://git.secretlab.ca/git/linux-2.6 next-net
>
> You know, if you had actually based this tree on net-next-2.6
> I could have pulled from it. =A0I actually tried, and I got a
> lot of upstream stuff I wasn't ready to get in that tree just
> yet :-/

I know, but the tree I based it on was what I actually tested against.
 When it came to publishing, I wasn't going to rebase and push out
something untested.  I hadn't expected it to get pulled so quickly!
Thanks!

g.

>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
