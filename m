From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
 present
Date: Thu, 17 Nov 2011 23:36:57 +0100
Message-ID: <4EC58C89.7020906@gmail.com>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com> <20111117.160405.368943784304624880.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vfalico@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net,
	fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61818 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173Ab1KQWg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 17:36:57 -0500
Received: by wwe5 with SMTP id 5so3890307wwe.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 14:36:56 -0800 (PST)
In-Reply-To: <20111117.160405.368943784304624880.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/11/2011 22:04, David Miller a =E9crit :
> From: Veaceslav Falico<vfalico@redhat.com>
> Date: Tue, 15 Nov 2011 17:44:42 +0100
>
>> When changing mode via bonding's sysfs, the slaves are not initializ=
ed
>> correctly. Forbid to change modes with slaves present to ensure that=
 every
>> slave is initialized correctly via bond_enslave().
>>
>> Signed-off-by: Veaceslav Falico<vfalico@redhat.com>
>
> Lots of discussion... what is the final verdict on this patch bonding=
 folks?

Now looks good to me, and as all others participants agreed at the begi=
nning, I think it's good for=20
everyone.

	Nicolas.
