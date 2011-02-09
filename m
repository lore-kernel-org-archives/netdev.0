From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for February 3 (netfilter)
Date: Wed, 09 Feb 2011 07:51:44 -0800
Message-ID: <4D52B810.403@oracle.com>
References: <20110203160034.44ae3247.sfr@canb.auug.org.au> <20110204111511.1f4d6706.randy.dunlap@oracle.com> <4D524079.1000908@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D524079.1000908@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/08/11 23:21, Patrick McHardy wrote:
> Am 04.02.2011 20:15, schrieb Randy Dunlap:
>> On Thu, 3 Feb 2011 16:00:34 +1100 Stephen Rothwell wrote:
>>
>>> Hi all,
>>>
>>> Changes since 20110202:
>>
>> When SYSCTL and PROC_FS and NETFILTER_NETLINK are not enabled:
>>
>> net/built-in.o: In function `try_to_load_type':
>> ip_set_core.c:(.text+0x3ab49): undefined reference to `nfnl_unlock'
>> ip_set_core.c:(.text+0x3ab4e): undefined reference to `nfnl_lock'
> 
> Does this patch fix the problem?

Yes, it does.  Thanks.

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
