From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: Ethernet bug at Upstream-v3.15-rcx on Lager.
Date: Fri, 30 May 2014 15:04:34 +0100
Message-ID: <53888FF2.8040505@codethink.co.uk>
References: <53745E88.7040108@jinso.co.jp> <5374F753.70203@cogentembedded.com> <537564FC.4090905@jinso.co.jp> <5375A877.1090606@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>
To: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	cm-hiep@jinso.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:33899 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751529AbaE3OEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 10:04:40 -0400
In-Reply-To: <5375A877.1090606@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/05/14 06:56, Yoshihiro Shimoda wrote:
> Hi Hiep-san,
>=20
> (2014/05/16 10:08), =E3=82=AB=E3=82=AA=E3=80=80=E3=83=9F=E3=83=B3=E3=80=
=80=E3=83=92=E3=82=A7=E3=83=83=E3=83=97 wrote:
>>>
>>>> Please review it when you have time.
>>>
>>>    Please try this patch:
>>>
>>> http://marc.info/?l=3Dlinux-netdev&m=3D139602519809181
>>>
>> I have tested this patch on v3.15.0-rc5-00077-g14186fe, and results =
are the message of
>> "sh-eth r8a7790-ether eth0: Receive FIFO Overflow" has disappeared a=
nd sending datagrams is good.
>> (Bandwidth 10M to 100M: Test with 5/5 times by script and by hand ar=
e good)
>>
>=20
> It's nice!
> So, I hope the patch is merged in upstream.
> However, the patch's change log mentioned r8a7790 only.
> The r8a7791's ethernet controller also has this bit.

The bit update covers both of them as the r8a7790 and r8a7791 both shar=
e
the same configuration structure.

I re-sent the patch but didn't find your email post until after I had
sent it, otherwise I would have mentioned your testing specifically. In
future it would be helpful if you could do the following

- Mention driver by name in the subject line
- Search the list for previous mentions and reply to that/those threads=
=2E


--=20
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
