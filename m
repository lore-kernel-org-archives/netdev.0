From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v2] include/linux: printk is needed in filter.h when CONFIG_BPF_JIT
 is defined
Date: Sat, 30 Mar 2013 11:41:58 +0800
Message-ID: <51565F06.8070608@asianux.com>
References: <5154ED65.5090607@asianux.com> <20130329.153447.426374969178935845.davem@davemloft.net> <515657BF.7010101@asianux.com> <20130329.233220.2002219172165994260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: edumazet@google.com, dborkman@redhat.com, wad@chromium.org,
	eparis@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:50732 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757689Ab3C3Dm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 23:42:29 -0400
In-Reply-To: <20130329.233220.2002219172165994260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B403=E6=9C=8830=E6=97=A5 11:32, David Miller wrote:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Sat, 30 Mar 2013 11:10:55 +0800
>=20
>> > On 2013=1B$BG/=1B(B03=1B$B7n=1B(B30=1B$BF|=1B(B 03:34, David Mille=
r wrote:
>>> >> From: Chen Gang <gang.chen@asianux.com>
>>> >> Date: Fri, 29 Mar 2013 09:24:53 +0800
>>> >>=20
>>>>> >>> >=20
>>>>> >>> >   for make V=3D1 EXTRA_CFLAGS=3D-W ARCH=3Darm allmodconfig
>>>>> >>> >     printk is need when CONFIG_BPF_JIT is defined
>>>>> >>> >     or it will report pr_err and print_hex_dump are implici=
t declaration
>>>>> >>> >=20
>>>>> >>> > Signed-off-by: Chen Gang <gang.chen@asianux.com>
>>> >> There are no references to pr_err nor print_hex_dump in this
>>> >> filter.h header file.
>> >=20
>> >   maybe we see the different tree.
>> >   I find it in next-20130328.
> When you submit patches, always mention explicitly what tree you
> want the patch applied to.
>=20
> In this case, this appropriate tree to be "net-next" since that
> is the tree where the problem actually exists.

  I should notice, next time.

>=20
> Patch applied, thanks.
>=20
>=20

  thanks, too.


--=20
Chen Gang

Asianux Corporation
