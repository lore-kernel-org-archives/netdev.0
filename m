From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: ipmr/ip6mr: add support for keeping an entry age
Date: Fri, 15 Jul 2016 23:11:15 -0700
Message-ID: <8FE06EF5-DBAA-4915-938B-A7B7736E5E35@cumulusnetworks.com>
References: <1468508930-32720-1-git-send-email-nikolay@cumulusnetworks.com> <1468513707-19016-1-git-send-email-nikolay@cumulusnetworks.com> <20160715.225608.440125257853766623.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	roopa@cumulusnetworks.com, shm@cumulusnetworks.com,
	sashok@cumulusnetworks.com, sharpd@cumulusnetworks.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33045 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbcGPGLU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 02:11:20 -0400
Received: by mail-pa0-f43.google.com with SMTP id ks6so45384108pab.0
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 23:11:20 -0700 (PDT)
In-Reply-To: <20160715.225608.440125257853766623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jul 15, 2016, at 10:56 PM, David Miller <davem@davemloft.net> wrot=
e:
>=20
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Date: Thu, 14 Jul 2016 19:28:27 +0300
>=20
>> In preparation for hardware offloading of ipmr/ip6mr we need an
>> interface that allows to check (and later update) the age of entries=
=2E
>> Relying on stats alone can show activity but not actual age of the e=
ntry,
>> furthermore when there're tens of thousands of entries a lot of the
>> hardware implementations only support "hit" bits which are cleared o=
n
>> read to denote that the entry was active and shouldn't be aged out,
>> these can then be naturally translated into age timestamp and will b=
e
>> compatible with the software forwarding age. Using a lastuse entry d=
oesn't
>> affect performance because the members in that cache line are writte=
n to
>> along with the age.
>> Since all new users are encouraged to use ipmr via netlink, this is
>> exported via the RTA_EXPIRES attribute.
>> Also do a minor local variable declaration style adjustment - arrang=
e them
>> longest to shortest.
>>=20
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
>> CC: Shrijeet Mukherjee <shm@cumulusnetworks.com>
>> CC: Satish Ashok <sashok@cumulusnetworks.com>
>> CC: Donald Sharp <sharpd@cumulusnetworks.com>
>> CC: David S. Miller <davem@davemloft.net>
>> CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
>> CC: James Morris <jmorris@namei.org>
>> CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
>> CC: Patrick McHardy <kaber@trash.net>
>> ---
>> v2: Just reuse RTA_EXPIRES instead to minimize the attr size and sim=
plify,
>> others will be added when needed
>=20
> Why are your dates on these changes in the past?
>=20
> Having them in the past messes up the ordering on patchwork because
> patchwork orders incoming patches by date, and therefore I can't just
> look at the first page to see "newer" submissions.
>=20
> So please don't do whatever propagates commit dates into your emails,
> or whatever is causing this problem.  It's best always to use the
> current time.

Hmm, it seems my VM has its time zone messed up and since I=E2=80=99m i=
n California right now the dates
come out wrong. Sorry about that, would you like me to resubmit the pat=
ch ?

Thanks,
 Nik
