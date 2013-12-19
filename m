From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Subject: Re: [net-next/master PATCH] lib: fix compile warning in hashlib_init
Date: Thu, 19 Dec 2013 09:36:20 +0800
Message-ID: <52B24D94.6090600@cn.fujitsu.com>
References: <1387415314-21786-1-git-send-email-gaowanlong@cn.fujitsu.com> <20131219011506.GA27326@localhost> <52B24C92.8050201@iogearbox.net>
Reply-To: gaowanlong@cn.fujitsu.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>, davem@davemloft.net,
	ffusco@redhat.com, kbuild-all@01.org,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <borkmann@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52B24C92.8050201@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/19/2013 09:32 AM, Daniel Borkmann wrote:
> On 12/19/2013 02:15 AM, Fengguang Wu wrote:
>> CC the list.
>>
>> On Thu, Dec 19, 2013 at 09:08:34AM +0800, Wanlong Gao wrote:
>>> /git/linux/lib/hash.c: In function 'hashlib_init':
>>> /git/linux/lib/hash.c:35:2: warning: passing argument 1 of 'setup_arch_fast_hash' from incompatible pointer type [enabled by default]
>>> /git/linux/include/asm-generic/hash.h:5:20: note: expected 'struct arch_hash_ops *' but argument is of type 'struct fast_hash_ops *'
>>>
>>> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
>>> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> 
> That's already in netdev patchwork:
> 
> http://patchwork.ozlabs.org/patch/302908/

Nice, thank you.

Regards,
Wanlong Gao

> 
> Thanks !
> 
