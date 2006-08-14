From: Laurent Riffard <laurent.riffard@free.fr>
Subject: Re: 2.6.18-rc4-mm1: eth0: trigger_send() called with the transmitter
 busy
Date: Mon, 14 Aug 2006 22:06:25 +0200
Message-ID: <44E0D7C1.7040509@free.fr>
References: <20060813012454.f1d52189.akpm@osdl.org>	<44E08AF7.9060508@free.fr> <20060814095016.04d178ab.akpm@osdl.org> <44E0B72C.6010503@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kernel development list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:65260 "EHLO smtp5-g19.free.fr")
	by vger.kernel.org with ESMTP id S932625AbWHNUEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 16:04:54 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <44E0B72C.6010503@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 14.08.2006 19:47, Laurent Riffard a =E9crit :
> Le 14.08.2006 18:50, Andrew Morton a =E9crit :
>> On Mon, 14 Aug 2006 16:38:47 +0200
>> Laurent Riffard <laurent.riffard@free.fr> wrote:
>>
>>> Le 13.08.2006 10:24, Andrew Morton a __crit :
>>>> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.=
18-rc4/2.6.18-rc4-mm1/
>>> Hello,
>>>
>>> This morning, while trying to suspend to disk, my box started to lo=
op=20
>>> displaying the following message:
>>> eth0: trigger_send() called with the transmitter busy.
>>>
>>> Here is the scenario. I booted 2.6.18-rc4-mm1 with this command lin=
e:
>>> root=3D/dev/vglinux1/lvroot video=3Dvesafb:ywrap,mtrr splash=3Dsile=
nt resume=3D/dev/hdb7 netconsole=3D@192.163.0.3/,@192.168.0.1/00:0E:9B:=
91:ED:72 init 1
>>>
>>> Then I issued:
>>> # echo 6 > /proc/sys/kernel/printk
>>> # echo disk > /sys/power/state
>> ne2k isn't <ahem> the most actively-maintained driver.
>>
>> But most (I think all) net drivers have problems during suspend when
>> netconsole is active.  Does disabling netconsole help?
>=20
> Yes it does.=20
> =20
>> Did this operation work OK in earlier kernels, with netconsole enabl=
ed?
>=20
> It's the first time I see such a message. I can't speak for 2.6.18-rc=
3-mm2=20
> because it could not suspend at all (did hang right after=20
> "echo disk > /sys/power/state"), but it worked in earlier kernels.
>=20
> I'll try with plain 2.6.18-rc4.

Same problem with 2.6.18-rc4. I'll try earlier -rc kernel tomorrow.
--=20
laurent
