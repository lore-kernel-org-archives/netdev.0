From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [OOPS] less /proc/net/igmp
Date: Tue, 26 Aug 2003 15:03:31 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030826.150331.102449369.yoshfuji@linux-ipv6.org>
References: <20030825163206.GA1340@penguin.penguin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sebek64@post.cz
In-Reply-To: <20030825163206.GA1340@penguin.penguin>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <20030825163206.GA1340@penguin.penguin> (at Mon, 25 Aug 2003 18:32:06 +0200), Marcel Sebek <sebek64@post.cz> says:

> This Oops appears on 2.5.74+ kernels (including 2.6.0-test4) when
> I'm trying to read /proc/net/igmp with 'less', 'cat' displays
> the file content without oops:
:
> [snip]
>  ...
> bash# mount /proc
> bash# cat /proc/net/igmp
> Idx	Device    : Count Querier	Group    Users Timer	Reporter
> bash# less /proc/net/igmp
> Idx	Device    : Count Querier	Group    Users Timer	Reporter
> bash# ifup -a
> bash# cat /proc/net/igmp
> Idx	Device    : Count Querier	Group    Users Timer	Reporter
> 1	lo        :     0      V2
> 				010000E0     1 0:FFFA22F0		0
> bash# less /proc/net/igmp
> Unable to handle kernel paging request at virtual address 08051be0
>  printing eip:
> 08051be0
> *pde = 0fb66067
> *pfe = 00000000
> Oops: 0004 [#1]
> CPU:    0
> EIP:    0073:[<08051be0>]    Not tainted
> EFLAGS: 00010246
> EIP is at 0x8051be0
> eax: 0805fb68   ebx: 00000001   ecx: 00000000   edx: 00000019
> esi: 08060649   edi: 08057543   ebp: bffffd8c   esp: bfffda50
> ds: 007b   es: 007b   ss: 007b
> Process less (pid 20, threadinfo = cfab6000 task = c13560cd)
>  <0>Kernel panic: Fatal exception in interrupt
> In interrupt handler - not syncing

I could not reproduce this issue.  anyone?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
