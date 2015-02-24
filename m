From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH] net: cadence: Enable MACB driver for ARM64
Date: Tue, 24 Feb 2015 15:04:44 +0100
Message-ID: <6951266498504938902769049489b60b@BN1BFFO11FD028.protection.gbl>
References: <5a2ef83a03f6df78c8de643a19fb3f6105d892f4.1424763946.git.michal.simek@xilinx.com>
 <59CA6960-8233-4D87-A337-0C7E10FD562A@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, <monstr@monstr.eu>,
	Nicolas FERRE <nicolas.ferre@atmel.com>,
	<netdev@vger.kernel.org>
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Michal Simek <michal.simek@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59CA6960-8233-4D87-A337-0C7E10FD562A@jcrosoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/24/2015 01:12 PM, Jean-Christophe PLAGNIOL-VILLARD wrote:
>=20
>> On Feb 24, 2015, at 3:45 PM, Michal Simek <michal.simek@xilinx.com> =
wrote:
>>
>> This driver is used on new Xilinx ZynqMP SoC.
>>
>> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
>> Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
>> ---
>>
>> drivers/net/ethernet/cadence/Kconfig | 4 ++--
>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethe=
rnet/cadence/Kconfig
>> index 321d2ad235d9..4562f90c0348 100644
>> --- a/drivers/net/ethernet/cadence/Kconfig
>> +++ b/drivers/net/ethernet/cadence/Kconfig
>> @@ -4,7 +4,7 @@
>>
>> config NET_CADENCE
>> 	bool "Cadence devices"
>> -	depends on HAS_IOMEM && (ARM || AVR32 || MICROBLAZE || COMPILE_TES=
T)
>> +	depends on HAS_IOMEM && (ARM || ARM64 || AVR32 || MICROBLAZE || CO=
MPILE_TEST)
>=20
> drop the arch test just put HAS_IOMEM

ok. Let me push it to Fenguang testing system if this will work.

Thanks,
Michal
