From: David Miller <davem@davemloft.net>
Subject: Re: [net-next/master PATCH] lib: fix compile warning in
 hashlib_init
Date: Thu, 19 Dec 2013 00:15:13 -0500 (EST)
Message-ID: <20131219.001513.1709782271902847928.davem@davemloft.net>
References: <1387415314-21786-1-git-send-email-gaowanlong@cn.fujitsu.com>
	<20131219011506.GA27326@localhost>
	<52B24C92.8050201@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, gaowanlong@cn.fujitsu.com,
	ffusco@redhat.com, kbuild-all@01.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: borkmann@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52B24C92.8050201@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <borkmann@iogearbox.net>
Date: Thu, 19 Dec 2013 02:32:02 +0100

> On 12/19/2013 02:15 AM, Fengguang Wu wrote:
>> CC the list.
>>
>> On Thu, Dec 19, 2013 at 09:08:34AM +0800, Wanlong Gao wrote:
>>> /git/linux/lib/hash.c: In function 'hashlib_init':
>>> /git/linux/lib/hash.c:35:2: warning: passing argument 1 of
>>> 'setup_arch_fast_hash' from incompatible pointer type [enabled by
>>> default]
>>> /git/linux/include/asm-generic/hash.h:5:20: note: expected 'struct
>>> arch_hash_ops *' but argument is of type 'struct fast_hash_ops *'
>>>
>>> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
>>> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> 
> That's already in netdev patchwork:
> 
> http://patchwork.ozlabs.org/patch/302908/

And I've applied it, thanks.
