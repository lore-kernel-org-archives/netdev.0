From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH] net, vxlan Fix compile warning
Date: Fri, 13 Sep 2013 10:23:51 -0400
Message-ID: <52331FF7.3070905@redhat.com>
References: <1379075352-20051-1-git-send-email-prarit@redhat.com> <20130913072028.54b1c28d@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jpirko@redhat.com, tgraf@redhat.com,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5612 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757040Ab3IMOXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Sep 2013 10:23:54 -0400
In-Reply-To: <20130913072028.54b1c28d@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/13/2013 10:20 AM, Stephen Hemminger wrote:
> On Fri, 13 Sep 2013 08:29:12 -0400
> Prarit Bhargava <prarit@redhat.com> wrote:
>=20
>> Fix a unintialized variable warning.
>>
>> drivers/net/vxlan.c: In function =E2=80=98vxlan_sock_add=E2=80=99:
>> drivers/net/vxlan.c:2240:11: error: =E2=80=98sock=E2=80=99 may be us=
ed uninitialized in this function [-Werror=3Dmaybe-uninitialized]
>>   vs->sock =3D sock;
>>            ^
>> drivers/net/vxlan.c:2217:17: note: =E2=80=98sock=E2=80=99 was declar=
ed here
>>   struct socket *sock;
>>                  ^
>>
>> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
>> Cc: jpirko@redhat.com
>> Cc: tgraf@redhat.com
>> Cc: "David S. Miller" <davem@davemloft.net>
>=20
> Which compiler version? Gcc 4.6 is known to be stupid,
> and I would rather not change the source if it is only caused
> by a gcc bug fixed in a later release.

Hi Stephen,

[root@intel-rosecity-06 ~]# gcc --version
gcc (GCC) 4.8.1 20130603 (Red Hat 4.8.1-1)
Copyright (C) 2013 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is=
 NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURP=
OSE.

P.
