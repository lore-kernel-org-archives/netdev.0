From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ping: fix build failure
Date: Tue, 17 May 2011 14:00:04 -0400 (EDT)
Message-ID: <20110517.140004.2294213911709293397.davem@davemloft.net>
References: <20110516.153844.1072050131335197211.davem@davemloft.net>
	<20110517101656.GA28685@albatros>
	<20110517084125.77b543c8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: segoon@openwall.com, sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110517084125.77b543c8.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 17 May 2011 08:41:25 -0700

> On Tue, 17 May 2011 14:16:56 +0400 Vasiliy Kulikov wrote:
> 
>> On Mon, May 16, 2011 at 15:38 -0400, David Miller wrote:
>> > From: Randy Dunlap <randy.dunlap@oracle.com>
>> > Date: Mon, 16 May 2011 12:35:34 -0700
>> > 
>> > > On Mon, 16 May 2011 15:10:19 +1000 Stephen Rothwell wrote:
>> > > when CONFIG_PROC_SYSCTL is not enabled:
>> > > 
>> > > ping.c:(.text+0x52af3): undefined reference to `inet_get_ping_group_range_net'
>> > 
>> > Vasiliy, please fix this.
>> 
>> I wonder whether there is any way to test such unusual configurations?
>> Only randconfig or are there any (partly-)automated tools for it?
>> 
>> 
>> [PATCH] net: ping: fix build failure
>> 
>> If CONFIG_PROC_SYSCTL=n the building process fails:
>> 
>>     ping.c:(.text+0x52af3): undefined reference to `inet_get_ping_group_range_net'
>> 
>> Moved inet_get_ping_group_range_net() to ping.c.
>> 
>> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
>> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
> 
> Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks everyone.
