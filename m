From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Wed, 28 Mar 2007 08:02:21 +0200
Message-ID: <460A04ED.5050203@cosmosbay.com>
References: <20070327214754.GA11677@dag-work>
 <20070327.153025.45876618.davem@davemloft.net> <4609A42A.4040304@mvista.com>
 <20070327.163620.54190045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mhuth@mvista.com, dagriego@gmail.com, davem@davemloft.ne,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604005mt.neufgp.fr ([84.96.92.11]:52180 "EHLO smtp.Neuf.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752032AbXC1GCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 02:02:24 -0400
Received: from [192.168.30.10] ([86.66.237.74]) by sp604005mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0JFL00AK9NFX8ZB1@sp604005mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Wed, 28 Mar 2007 08:02:22 +0200 (CEST)
In-reply-to: <20070327.163620.54190045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Mark Huth <mhuth@mvista.com>
> Date: Tue, 27 Mar 2007 16:09:30 -0700
>=20
>> Actually, there are legitimate uses for this sort of API.  The patch=
=20
>> allows an administrator to kill specific connections that are in use=
 by=20
>> other applications, where the close is not available, since the sock=
et=20
>> is owned by another process.
>=20
> Anything that wants to act as an external agent to manipulate
> or terminate connections should use netfilter.

This is what I thought too at the begining.

But after some thinking I recalled having to reboot machines just becau=
se=20
netfilter was not in (because of noticeable performance hit), and I cou=
ld find=20
  the tree to compile netfilter as modules..

When I saw revoke() work in progess, I did react like you : This is com=
ing=20
from hell...

