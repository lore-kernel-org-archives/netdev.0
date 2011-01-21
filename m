From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: 2.6.38-rc1: arp triggers RTNL assertion
Date: Fri, 21 Jan 2011 15:02:34 +0100
Message-ID: <20110121140234.GA2724@riccoc20.at.omicron.at>
References: <20110121061758.GA2247@fifty-fifty.audible.transient.net>
 <1295593946.2613.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Heilman <jamie@audible.transient.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1295593946.2613.52.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 21, 2011 at 08:12:26AM +0100, Eric Dumazet wrote:
> Thanks for the report, I am looking at this right now.

FYI, I had this too. Happens every time I use my UMTS modem.

Kernel: private branch from e744070fd4ff9d3114277e52d77afa21579adce2


Jan 13 05:07:23 riccoc20 pppd[12961]: Serial connection established.
Jan 13 05:07:23 riccoc20 pppd[12961]: Using interface ppp0
Jan 13 05:07:23 riccoc20 pppd[12961]: Connect: ppp0 <--> /dev/ttyACM0
Jan 13 05:07:24 riccoc20 pppd[12961]: PAP authentication succeeded
Jan 13 05:07:25 riccoc20 pppd[12961]: replacing old default route to eth0 [10.0.0.1]
Jan 13 05:07:25 riccoc20 pppd[12961]: found interface eth0 for proxy arp
Jan 13 05:07:25 riccoc20 pppd[12961]: local  IP address 46.124.43.179
Jan 13 05:07:25 riccoc20 pppd[12961]: remote IP address 10.6.6.6
Jan 13 05:07:25 riccoc20 pppd[12961]: primary   DNS address 213.162.69.169
Jan 13 05:07:25 riccoc20 pppd[12961]: secondary DNS address 213.162.65.1
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088740] RTNL: assertion failed at /home/cochran/work/git/net-next-2.6/net/core/neighbour.c (589)
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088746] Pid: 12961, comm: pppd Tainted: P            2.6.37+ #3
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088748] Call Trace:
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088757]  [<c04da48f>] ? pneigh_lookup+0x1af/0x1c0
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088761]  [<c05254fe>] ? arp_req_set+0x18e/0x290
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088764]  [<c04dbb62>] ? __rtnl_unlock+0x12/0x20
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088767]  [<c04cd972>] ? netdev_run_todo+0x42/0x230
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088771]  [<c0329821>] ? apparmor_capable+0x21/0x70
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088774]  [<c04cf81d>] ? dev_get_by_name_rcu+0x8d/0xb0
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088777]  [<c0525844>] ? arp_ioctl+0x244/0x260
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088780]  [<c052a5e5>] ? inet_ioctl+0xa5/0xb0
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088784]  [<c04bc6bd>] ? sock_ioctl+0x6d/0x290
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088786]  [<c04bc650>] ? sock_ioctl+0x0/0x290
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088790]  [<c02222cc>] ? do_vfs_ioctl+0x8c/0x620
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088794]  [<c05ab22a>] ? do_page_fault+0x1ca/0x450
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088796]  [<c04be7bb>] ? sys_send+0x3b/0x40
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088798]  [<c04bf3b8>] ? sys_socketcall+0x1d8/0x2a0
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088801]  [<c02228c7>] ? sys_ioctl+0x67/0x80
Jan 13 05:07:25 riccoc20 kernel: [ 3151.088804]  [<c05a80a4>] ? syscall_call+0x7/0xb
Jan 13 05:07:31 riccoc20 ntpdate[13030]: no server suitable for synchronization found
