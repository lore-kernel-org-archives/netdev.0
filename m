From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] 2.6.11-rc1-mm1: ip_tables.c: ipt_find_target must be
 EXPORT_SYMBOL'ed
Date: Fri, 14 Jan 2005 18:43:00 +0100
Message-ID: <41E804A4.9040003@trash.net>
References: <20050114002352.5a038710.akpm@osdl.org> <20050114173538.GB4274@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Rusty Russell <rusty@rustcorp.com.au>,
        linux-kernel@vger.kernel.org, coreteam@netfilter.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050114173538.GB4274@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:

>On Fri, Jan 14, 2005 at 12:23:52AM -0800, Andrew Morton wrote:
>
>>...
>>All 434 patches:
>>...
>>restore-net-sched-iptc-after-iptables-kmod-cleanup.patch
>>  Restore net/sched/ipt.c After iptables Kmod Cleanup
>>...
>>
>
>This causes the following error with CONFIG_NET_ACT_IPT=m:
>
><--  snip  -->
>
>if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.6.11-rc1-mm1; fi
>WARNING: /lib/modules/2.6.11-rc1-mm1/kernel/net/sched/ipt.ko needs unknown symbol ipt_find_target
>
><--  snip  -->
>
The fix is already in Dave's tree.

Regards
Patrick
