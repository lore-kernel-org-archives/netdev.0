From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] net: ping: fix build failure
Date: Tue, 17 May 2011 07:58:16 -0700
Message-ID: <4DD28D08.1030401@oracle.com>
References: <20110516151019.be338f1c.sfr@canb.auug.org.au> <20110516123534.5d3a51b9.randy.dunlap@oracle.com> <20110516.153844.1072050131335197211.davem@davemloft.net> <20110517101656.GA28685@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110517101656.GA28685@albatros>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/17/11 03:16, Vasiliy Kulikov wrote:
> On Mon, May 16, 2011 at 15:38 -0400, David Miller wrote:
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>> Date: Mon, 16 May 2011 12:35:34 -0700
>>
>>> On Mon, 16 May 2011 15:10:19 +1000 Stephen Rothwell wrote:
>>> when CONFIG_PROC_SYSCTL is not enabled:
>>>
>>> ping.c:(.text+0x52af3): undefined reference to `inet_get_ping_group_range_net'
>>
>> Vasiliy, please fix this.
> 
> I wonder whether there is any way to test such unusual configurations?
> Only randconfig or are there any (partly-)automated tools for it?

Hi,

I do automated (cron) randconfigs nightly and occasionally I run a script
that builds a kernel with each one of these options disabled (although
lately CONFIG_PM is not being disabled, but I'll fix that one day):

BLOCK HOTPLUG INET INPUT MAGIC_SYSRQ NET PCI PM PROC_FS SMP SYSFS

Hm, I should add SYSCTL (and/or PROC_SYSCTL) to that list.  It often has issues.

-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
