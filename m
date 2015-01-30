From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH net-next] drivers: net: cpsw: make cpsw_ale.c a module
 to allow re-use on Keystone
Date: Fri, 30 Jan 2015 15:26:32 +0530
Message-ID: <54CB5550.1020406@ti.com>
References: <1422573351-5603-1-git-send-email-m-karicheri2@ti.com> <1422573351-5603-2-git-send-email-m-karicheri2@ti.com> <54CB3E53.8050307@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Murali Karicheri <m-karicheri2@ti.com>, <w-kwok2@ti.com>,
	<davem@davemloft.net>, <tony@atomide.com>,
	<prabhakar.csengg@gmail.com>, <grygorii.strashko@ti.com>,
	<lokeshvutla@ti.com>, <mpa@pengutronix.de>,
	<lsorense@csclub.uwaterloo.ca>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54CB3E53.8050307@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 30 January 2015 01:48 PM, Mugunthan V N wrote:
> On Friday 30 January 2015 04:45 AM, Murali Karicheri wrote:
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
>> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
> 
> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
> 
> Will try to test this today/Monday.
> 
> 

I have tested this on DRA7 platform and passed tested ping.

Tested-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
