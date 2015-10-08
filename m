From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2 1/5] net: move net_get_random_once to lib
Date: Thu, 08 Oct 2015 08:42:03 +0200
Message-ID: <5616103B.2030805@iogearbox.net>
References: <201510081306.aKMKQcGQ%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, davem@davemloft.net, hannes@stressinduktion.org,
	ast@plumgrid.com, netdev@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38207 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbbJHGmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 02:42:11 -0400
In-Reply-To: <201510081306.aKMKQcGQ%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/2015 07:12 AM, kbuild test robot wrote:
> Hi Hannes,
>
> [auto build test WARNING on net-next/master -- if it's inappropriate base, please ignore]
>
> config: mips-ip27_defconfig (attached as .config)
> reproduce:
>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          # save the attached .config to linux build tree
>          make.cross ARCH=mips
>
> All warnings (new ones prefixed by >>):
>
>     mips-linux-gnu-ld: lib/lockref.o: warning: Inconsistent ISA between e_flags and .MIPS.abiflags
>     mips-linux-gnu-ld: lib/lockref.o: warning: Inconsistent ISA extensions between e_flags and .MIPS.abiflags
[...]
>     mips-linux-gnu-ld: lib/reciprocal_div.o: warning: Inconsistent ISA between e_flags and .MIPS.abiflags
>     mips-linux-gnu-ld: lib/reciprocal_div.o: warning: Inconsistent ISA extensions between e_flags and .MIPS.abiflags
>>> mips-linux-gnu-ld: lib/once.o: warning: Inconsistent ISA between e_flags and .MIPS.abiflags
>>> mips-linux-gnu-ld: lib/once.o: warning: Inconsistent ISA extensions between e_flags and .MIPS.abiflags

Looks like a known issue on MIPS given the warning is not new also on other object
files. Here was what was discussed recently on this subject on a refactoring patch
from David Ahern:

   https://patchwork.ozlabs.org/patch/525102/

Thanks!

>     mips-linux-gnu-ld: lib/string_helpers.o: warning: Inconsistent ISA between e_flags and .MIPS.abiflags
>     mips-linux-gnu-ld: lib/string_helpers.o: warning: Inconsistent ISA extensions between e_flags and .MIPS.abiflags
[...]
