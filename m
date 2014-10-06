From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH linux v2 1/1] fs/proc: use a rb tree for the directory
 entries
Date: Mon, 06 Oct 2014 18:14:48 -0400 (EDT)
Message-ID: <20141006.181448.1696747135961247651.davem@davemloft.net>
References: <542EA009.4060009@6wind.com>
	<1412605834-4417-1-git-send-email-nicolas.dichtel@6wind.com>
	<1412605834-4417-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, akpm@linux-foundation.org,
	adobriyan@gmail.com, rui.xiang@huawei.com, viro@zeniv.linux.org.uk,
	oleg@redhat.com, gorcunov@openvz.org,
	kirill.shutemov@linux.intel.com, grant.likely@secretlab.ca,
	tytso@mit.edu
To: nicolas.dichtel@6wind.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412605834-4417-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon,  6 Oct 2014 16:30:34 +0200

> The current implementation for the directories in /proc is using a single
> linked list. This is slow when handling directories with large numbers of
> entries (eg netdevice-related entries when lots of tunnels are opened).
> 
> This patch replaces this linked list by a red-black tree.
> 
> Here are some numbers:
> 
> dummy30000.batch contains 30 000 times 'link add type dummy'.
 ...
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

FWIW:

Acked-by: David S. Miller <davem@davemloft.net>
