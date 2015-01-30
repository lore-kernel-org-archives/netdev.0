From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH net-next] drivers: net: cpsw: make cpsw_ale.c a module
 to allow re-use on Keystone
Date: Fri, 30 Jan 2015 10:39:08 -0500
Message-ID: <54CBA59C.3000805@ti.com>
References: <1422573351-5603-1-git-send-email-m-karicheri2@ti.com> <1422573351-5603-2-git-send-email-m-karicheri2@ti.com> <1802322.NDR3d5ZRSA@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <w-kwok2@ti.com>, <davem@davemloft.net>, <mugunthanvnm@ti.com>,
	<tony@atomide.com>, <prabhakar.csengg@gmail.com>,
	<grygorii.strashko@ti.com>, <lokeshvutla@ti.com>,
	<mpa@pengutronix.de>, <lsorense@csclub.uwaterloo.ca>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1802322.NDR3d5ZRSA@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/29/2015 06:47 PM, Arnd Bergmann wrote:
> On Thursday 29 January 2015 18:15:51 Murali Karicheri wrote:
>> NetCP on Keystone has cpsw ale function similar to other TI SoCs
>> and this driver is re-used. To allow both ti cpsw and keystone netcp
>> to re-use the driver, convert the cpsw ale to a module and configure
>> it through Kconfig option CONFIG_TI_CPSW_ALE. Currently it is statically
>> linked to both TI CPSW and NetCP and this causes issues when the above
>> drivers are built as dynamic modules. This patch addresses this issue
>>
>> While at it, fix the Makefile and code to build both netcp_core and
>> netcp_ethss as dynamic modules. This is needed to support arm allmodconfig.
>> This also requires exporting of API calls provided by netcp_core so that
>> both the above can be dynamic modules.
>>
>> Signed-off-by: Murali Karicheri<m-karicheri2@ti.com>
>> ---
>>   drivers/net/ethernet/ti/Kconfig       |   19 +++++++++++++++++--
>>   drivers/net/ethernet/ti/Makefile      |    8 +++++---
>>   drivers/net/ethernet/ti/cpsw_ale.c    |   26 ++++++++++++++++++++++++--
>>   drivers/net/ethernet/ti/netcp_core.c  |    8 ++++++++
>>   drivers/net/ethernet/ti/netcp_ethss.c |    5 +++++
>>   5 files changed, 59 insertions(+), 7 deletions(-)
>
> I was hoping there would be a way without exporting all those symbols, but
> I also couldn't come up with a better solution. I'm putting this into the
> randconfig build test for now, but I'm guessing it's fine.
>
> Unless you hear something else from me tomorrow after the tests are through:
>
> Acked-by: Arnd Bergmann<arnd@arndb.de>
Arnd,

Oops! I think I have send v1 too soon with your Ack. Sorry for that. 
Hope nothing shows up bad in your test.

-- 
Murali Karicheri
Linux Kernel, Texas Instruments
