From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH V2 2/3] net-next: dsa: add multi cpu port support
Date: Tue, 30 May 2017 20:37:04 +0200
Message-ID: <7d8cdddb-f107-9945-f366-12d320ecb188@phrozen.org>
References: <201705302336.BC8366CF%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:58756 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751193AbdE3Sh2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 14:37:28 -0400
In-Reply-To: <201705302336.BC8366CF%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

the patch series is based on net-next from 12 hours ago and works fine 
on that tree. I compile and runtime tested it quite intensively on 
various boards

     John


On 30/05/17 17:38, kbuild test robot wrote:
> Hi John,
>
> [auto build test ERROR on net-next/master]
> [also build test ERROR on next-20170530]
> [cannot apply to v4.12-rc3]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/John-Crispin/Documentation-devicetree-add-multiple-cpu-port-DSA-binding/20170530-224954
> config: x86_64-randconfig-x014-201722 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>          # save the attached .config to linux build tree
>          make ARCH=x86_64
>
> All error/warnings (new ones prefixed by >>):
>
>     In file included from include/linux/ioport.h:12:0,
>                      from include/linux/device.h:16,
>                      from net//dsa/dsa2.c:13:
>     net//dsa/dsa2.c: In function 'dsa_ds_parse':
>>> net//dsa/dsa2.c:574:31: error: passing argument 1 of 'dsa_is_normal_port' from incompatible pointer type [-Werror=incompatible-pointer-types]
>        else if (dsa_is_normal_port(port))
>                                    ^
>     include/linux/compiler.h:160:30: note: in definition of macro '__trace_if'
>       if (__builtin_constant_p(!!(cond)) ? !!(cond) :   \
>                                   ^~~~
>>> net//dsa/dsa2.c:574:8: note: in expansion of macro 'if'
>        else if (dsa_is_normal_port(port))
>             ^~
>     In file included from net//dsa/dsa_priv.h:17:0,
>                      from net//dsa/dsa2.c:22:
>     include/net/dsa.h:264:20: note: expected 'struct dsa_switch *' but argument is of type 'struct dsa_port *'
>      static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
>                         ^~~~~~~~~~~~~~~~~~
>     In file included from include/linux/ioport.h:12:0,
>                      from include/linux/device.h:16,
>                      from net//dsa/dsa2.c:13:
>>> net//dsa/dsa2.c:574:12: error: too few arguments to function 'dsa_is_normal_port'
>        else if (dsa_is_normal_port(port))
>                 ^
>     include/linux/compiler.h:160:30: note: in definition of macro '__trace_if'
>       if (__builtin_constant_p(!!(cond)) ? !!(cond) :   \
>                                   ^~~~
>>> net//dsa/dsa2.c:574:8: note: in expansion of macro 'if'
>        else if (dsa_is_normal_port(port))
>             ^~
>     In file included from net//dsa/dsa_priv.h:17:0,
>                      from net//dsa/dsa2.c:22:
>     include/net/dsa.h:264:20: note: declared here
>      static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
>                         ^~~~~~~~~~~~~~~~~~
>     In file included from include/linux/ioport.h:12:0,
>                      from include/linux/device.h:16,
>                      from net//dsa/dsa2.c:13:
>>> net//dsa/dsa2.c:574:31: error: passing argument 1 of 'dsa_is_normal_port' from incompatible pointer type [-Werror=incompatible-pointer-types]
>        else if (dsa_is_normal_port(port))
>                                    ^
>     include/linux/compiler.h:160:42: note: in definition of macro '__trace_if'
>       if (__builtin_constant_p(!!(cond)) ? !!(cond) :   \
>                                               ^~~~
>>> net//dsa/dsa2.c:574:8: note: in expansion of macro 'if'
>        else if (dsa_is_normal_port(port))
>             ^~
>     In file included from net//dsa/dsa_priv.h:17:0,
>                      from net//dsa/dsa2.c:22:
>     include/net/dsa.h:264:20: note: expected 'struct dsa_switch *' but argument is of type 'struct dsa_port *'
>      static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
>                         ^~~~~~~~~~~~~~~~~~
>     In file included from include/linux/ioport.h:12:0,
>                      from include/linux/device.h:16,
>                      from net//dsa/dsa2.c:13:
>>> net//dsa/dsa2.c:574:12: error: too few arguments to function 'dsa_is_normal_port'
>        else if (dsa_is_normal_port(port))
>                 ^
>     include/linux/compiler.h:160:42: note: in definition of macro '__trace_if'
>       if (__builtin_constant_p(!!(cond)) ? !!(cond) :   \
>                                               ^~~~
>>> net//dsa/dsa2.c:574:8: note: in expansion of macro 'if'
>        else if (dsa_is_normal_port(port))
>             ^~
>     In file included from net//dsa/dsa_priv.h:17:0,
>                      from net//dsa/dsa2.c:22:
>     include/net/dsa.h:264:20: note: declared here
>      static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
>                         ^~~~~~~~~~~~~~~~~~
>     In file included from include/linux/ioport.h:12:0,
>                      from include/linux/device.h:16,
>                      from net//dsa/dsa2.c:13:
>>> net//dsa/dsa2.c:574:31: error: passing argument 1 of 'dsa_is_normal_port' from incompatible pointer type [-Werror=incompatible-pointer-types]
>        else if (dsa_is_normal_port(port))
>                                    ^
>     include/linux/compiler.h:171:16: note: in definition of macro '__trace_if'
>        ______r = !!(cond);     \
>                     ^~~~
>>> net//dsa/dsa2.c:574:8: note: in expansion of macro 'if'
>        else if (dsa_is_normal_port(port))
>             ^~
>     In file included from net//dsa/dsa_priv.h:17:0,
>                      from net//dsa/dsa2.c:22:
>     include/net/dsa.h:264:20: note: expected 'struct dsa_switch *' but argument is of type 'struct dsa_port *'
>      static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
>                         ^~~~~~~~~~~~~~~~~~
>     In file included from include/linux/ioport.h:12:0,
>                      from include/linux/device.h:16,
>                      from net//dsa/dsa2.c:13:
>>> net//dsa/dsa2.c:574:12: error: too few arguments to function 'dsa_is_normal_port'
>        else if (dsa_is_normal_port(port))
>                 ^
>     include/linux/compiler.h:171:16: note: in definition of macro '__trace_if'
>        ______r = !!(cond);     \
>                     ^~~~
>>> net//dsa/dsa2.c:574:8: note: in expansion of macro 'if'
>        else if (dsa_is_normal_port(port))
>             ^~
>     In file included from net//dsa/dsa_priv.h:17:0,
>                      from net//dsa/dsa2.c:22:
>     include/net/dsa.h:264:20: note: declared here
>      static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
>                         ^~~~~~~~~~~~~~~~~~
>     cc1: some warnings being treated as errors
>
> vim +/dsa_is_normal_port +574 net//dsa/dsa2.c
>
>     568			port = &ds->ports[index];
>     569			if (!dsa_port_is_valid(port))
>     570				continue;
>     571	
>     572			if (dsa_port_is_cpu(port))
>     573				err = dsa_cpu_parse(port, index, dst, ds);
>   > 574			else if (dsa_is_normal_port(port))
>     575				err = dsa_user_parse(port->dn, index,  ds);
>     576	
>     577				if (err)
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
