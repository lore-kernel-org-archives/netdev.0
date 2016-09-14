From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: deprecate eth_change_mtu, remove usage
Date: Wed, 14 Sep 2016 14:45:12 -0400
Message-ID: <20160914184512.GB8644@redhat.com>
References: <20160912201106.47837-3-jarod@redhat.com>
 <201609140519.GHFnOaaT%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201609140519.GHFnOaaT%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 05:59:14AM +0800, kbuild test robot wrote:
> Hi Jarod,
> 
> [auto build test ERROR on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Jarod-Wilson/net-centralize-net_device-min-max-MTU-checking/20160913-042130
> config: mips-xway_defconfig (attached as .config)
> compiler: mips-linux-gnu-gcc (Debian 5.4.0-6) 5.4.0 20160609
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=mips 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    drivers/net/ethernet/lantiq_etop.c: In function 'ltq_etop_change_mtu':
> >> drivers/net/ethernet/lantiq_etop.c:524:7: error: 'ret' undeclared (first use in this function)
>      if (!ret) {
>           ^
>    drivers/net/ethernet/lantiq_etop.c:524:7: note: each undeclared identifier is reported only once for each function it appears in
> >> drivers/net/ethernet/lantiq_etop.c:534:1: warning: control reaches end of non-void function [-Wreturn-type]
>     }
>     ^

Crap. Did build-test, but only x86_64, so I missed this apparently
mips-specific breakage. Locally fixed up, but waiting to see if anyone has
any other feedback about these two patches before I go ahead with v2. Also
have a ~15-part drivers/net/ethernet/ cleanup series ready and waiting,
pending some traction with the core infra.

-- 
Jarod Wilson
jarod@redhat.com
