From: Jeff Garzik <jgarzik@pobox.com>
Subject: BK-current build breakage
Date: Thu, 06 Jan 2005 18:51:28 -0500
Message-ID: <41DDCF00.6070405@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

net/built-in.o(.text+0x25858): In function `tcf_ipt_init':
net/sched/ipt.c:63: undefined reference to `__ipt_find_target_lock'
net/built-in.o(.text+0x25873):net/sched/ipt.c:78: undefined reference to 
`__ipt_mutex_up'
make: *** [.tmp_vmlinux1] Error 1
