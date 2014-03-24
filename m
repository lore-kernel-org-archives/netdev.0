From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: gre: Fix null pointer dereference in
 gre_cisco_err()
Date: Mon, 24 Mar 2014 15:14:17 -0400 (EDT)
Message-ID: <20140324.151417.474668383309974516.davem@davemloft.net>
References: <1395646471-637-1-git-send-email-asuka.com@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: asuka.com@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395646471-637-1-git-send-email-asuka.com@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Zhang <asuka.com@163.com>
Date: Mon, 24 Mar 2014 15:34:31 +0800

> When use the gre vport, openvswitch register a gre_cisco_protocol but
> does not supply a err_handler with it. The gre_cisco_err() call the
> err_handler without existence check, cause the kernel crash.
> 
> This patch base on v3.14-rc7. But the bug affect all kernel newer than
> 3.11!
> 
> Signed-off-by: Wei Zhang <asuka.com@163.com>

Rather, openvswitch should provide an appropriate ->err_handler() that
returns PACKET_RCVD or PACKET_REJECT.

I'm not applying this patch.
