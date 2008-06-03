From: Andy Fleming <afleming@freescale.com>
Subject: Re: [RFC] Make board force selection of PHYLIB
Date: Tue, 3 Jun 2008 13:11:21 -0500
Message-ID: <BC4BFA45-2CD1-4834-AEFB-58D1133B7F22@freescale.com>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net>
	<484419EE.5040503@garzik.org>
	<1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org>
	<48442239.7090906@garzik.org>
	<BF15FEBB-4876-4B16-915B-1D21BF989DA8@kernel.crashing.org>
	<83820D83-487C-4586-9867-F4226A87A276@freescale.com>
	<48445851.4090105@garzik.org>
	<095F258F-72DD-4F27-A457-A57D9FAA1E76@kernel.crashing.org>
	<48448020.5020407@freescale.com>
	<Pine.LNX.4.64.0806030945540.21537@blarg.am.freescale.net>
	<20080603170022.GE9605@cs181133002.pp.htv.fi>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, linuxppc-dev@ozlabs.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20080603170022.GE9605@cs181133002.pp.htv.fi>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Jun 3, 2008, at 12:00, Adrian Bunk wrote:

> On Tue, Jun 03, 2008 at 09:47:19AM -0500, Kumar Gala wrote:
>> How is this as a fix.
>>
>> - k
>>
>> diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/ 
>> platforms/85xx/Kconfig
>> index 7ff29d5..9e5c884 100644
>> --- a/arch/powerpc/platforms/85xx/Kconfig
>> +++ b/arch/powerpc/platforms/85xx/Kconfig
>> @@ -34,6 +34,7 @@ config MPC85xx_MDS
>> 	bool "Freescale MPC85xx MDS"
>> 	select DEFAULT_UIMAGE
>> 	select QUICC_ENGINE
>> +	select PHYLIB if GIANFAR=m
>> 	help
>> 	  This option enables support for the MPC85xx MDS board
>
> The .config you sent me as an example didn't have GIANFAR set, so it
> couldn't help there.
>
> How early do the fixups have to run?
>
> I see two possible solutions:
> - let MPC85xx_MDS unconditionally select PHYLIB or
> - move the fixups to the gianfar driver

Just to reiterate the point:  The fixups are not only not gianfar- 
specific, they may not involve gianfar at all.  The 8568 has *two*  
types of built-in ethernet controllers, which use 4 PHYs (of one  
type).  The fixups are purely PHY-specific for this board.

Andy
