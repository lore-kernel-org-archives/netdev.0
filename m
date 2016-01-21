From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: question about samsung/sxgbe/sxgbe_xpcs.c
Date: Thu, 21 Jan 2016 07:04:17 -0700
Message-ID: <56A0E561.2030409@osg.samsung.com>
References: <alpine.DEB.2.10.1601191723250.2531@hadrien>
 <CAKocOOOFrEFLL0MWnn_bhBby8GeVH82A2wtaL9Tg9QTJC2Wprw@mail.gmail.com>
 <alpine.DEB.2.10.1601191918470.2531@hadrien>
 <20160119.143628.432983847877790677.davem@davemloft.net>
 <20160121051056.GA4373@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: julia.lawall@lip6.fr, shuahkhan@gmail.com, bh74.an@samsung.com,
	ks.giri@samsung.com, vipul.pandya@samsung.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?Q?J=ce=b5an_Sacren?= <sakiwit@gmail.com>,
	David Miller <davem@davemloft.net>, siva.kallam@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160121051056.GA4373@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/20/2016 10:10 PM, J=CE=B5an Sacren wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 19 Jan 2016 14:36:28 -0500
>>
>> From: Julia Lawall <julia.lawall@lip6.fr>
>> Date: Tue, 19 Jan 2016 19:54:20 +0100 (CET)
>=20
> [...]
>=20
>>> I just wondered.  I was looking at dependencies between networking =
files.
>>> This one stands out because nothing is dependenton it, even the fil=
es it
>>> is compiled with, and it doesn't contain the usual functions,
>>> register_netdev, etc.
>>
>> Even with that explanation, this is a bogus situation.
>>
>> There are no in-tree callers of this code.  It should be removed unt=
il there
>> are in-tree users.
>>
>> Nobody can figure out if the interface for this is done properly wit=
hout seeing
>> the call sites and how they work.  It is therefore impossible to rev=
iew this
>> code and judge it's design.
>>
>> If someone doesn't send me a removal patch, I will remove this code =
myself.
>=20
> I have the patch ready.
>=20
> Do you want me to submit it now during the merge window or wait till
> net-next opens up again?
>=20

My second attempt to locate the author for a comment
on this before it gets removed. Maybe this code could
be fixed just in case it is important for some product
out there.

I am cc'ing the original author in case he has any
comments.

thanks,
-- Shuah


--=20
Shuah Khan
Sr. Linux Kernel Developer
Open Source Innovation Group
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com | (970) 217-8978
