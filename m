From: Mike Sinkovsky <msink@permonline.ru>
Subject: Re: [PATCH v8 0/2] Ethernet drivers for WIZnet chips
Date: Thu, 05 Apr 2012 11:36:33 +0600
Message-ID: <4F7D2F61.8040601@permonline.ru>
References: <1333524216-23488-1-git-send-email-msink@permonline.ru><1333540660-30551-1-git-send-email-msink@trikom.ru> <20120404.211506.929057223227809703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	broonie@opensource.wolfsonmicro.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120404.211506.929057223227809703.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

05.04.2012 7:15, David Miller wrote:
> From: Mike Sinkovsky<msink@trikom.ru>
> Date: Wed,  4 Apr 2012 17:57:38 +0600
>
>> From: Mike Sinkovsky<msink@permonline.ru>
>>
>> Based on original driver from chip manufacturer, but nearly full rew=
ite.
>> Tested and used in production with Blackfin BF531 embedded processor=
=2E
>>
>> Signed-off-by: Mike Sinkovsky<msink@permonline.ru>
>
> I don't see the appropriate changes in your patches to make
> sure that drivers/net/ethernet/{Kconfig,Makefile} consider
> and traverse down into the wiznet/ subdirectory.
>
> Furthermore, once that is fixed these drivers generate warnings
> when built:
>
> drivers/net/ethernet/wiznet/w5300.c:708:8: warning: initialization fr=
om incompatible pointer type [enabled by default]
> drivers/net/ethernet/wiznet/w5300.c:708:8: warning: (near initializat=
ion for =A1w5300_pm_ops.suspend=A2) [enabled by default]
> drivers/net/ethernet/wiznet/w5300.c:708:8: warning: initialization fr=
om incompatible pointer type [enabled by default]
> drivers/net/ethernet/wiznet/w5300.c:708:8: warning: (near initializat=
ion for =A1w5300_pm_ops.resume=A2) [enabled by default]
> drivers/net/ethernet/wiznet/w5300.c:708:8: warning: initialization fr=
om incompatible pointer type [enabled by default]
> drivers/net/ethernet/wiznet/w5300.c:708:8: warning: (near initializat=
ion for =A1w5300_pm_ops.freeze=A2) [enabled by default]
> drivers/net/ethernet/wiznet/w5300.c:708:8: warning: initialization fr=
om incompatible pointer type [enabled by default]
> drivers/net/ethernet/wiznet/w5300.c:708:8: warning: (near initializat=
ion for =A1w5300_pm_ops.thaw=A2) [enabled by default]
> drivers/net/ethernet/wiznet/w5300.c:708:8: warning: initialization fr=
om incompatible pointer type [enabled by default]
> drivers/net/ethernet/wiznet/w5300.c:708:8: warning: (near initializat=
ion for =A1w5300_pm_ops.poweroff=A2) [enabled by default]
> drivers/net/ethernet/wiznet/w5300.c:708:8: warning: initialization fr=
om incompatible pointer type [enabled by default]
> drivers/net/ethernet/wiznet/w5300.c:708:8: warning: (near initializat=
ion for =A1w5300_pm_ops.restore=A2) [enabled by default]
>
> It seems that the arguments and return types for these operations hav=
e
> changed since you worked on these patches, but this should be easy
> to fix up.
>
> Please cure these two issues and I'll happily put these new drivers
> into net-next, and meanwhile you can continue to work with Eric
> Dumazet to correct the TX flow control and locking issues.
>
> Thanks.

=46ixed and posted v9.

Thanks.

--=20
Mike
