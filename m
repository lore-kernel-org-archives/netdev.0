From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] qed: fix kzalloc-simple.cocci warnings
Date: Fri, 02 Sep 2016 10:44:21 -0700
Message-ID: <1472838261.6758.74.camel@perches.com>
References: <201609011409.GGSqCknq%fengguang.wu@intel.com>
         <20160901064512.GA49421@lkp-sb04>
         <DM5PR11MB1723927908802E0D1C38C94D97E20@DM5PR11MB1723.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: "kbuild-all@01.org" <kbuild-all@01.org>,
        netdev <netdev@vger.kernel.org>,
        Ariel Elior <Ariel.Elior@qlogic.com>,
        Dept-Eng Everest Linux L2 <Dept-EngEverestLinuxL2@qlogic.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        kbuild test robot <fengguang.wu@intel.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DM5PR11MB1723927908802E0D1C38C94D97E20@DM5PR11MB1723.namprd11.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-09-01 at 07:37 +0000, Yuval Mintz wrote:
> > drivers/net/ethernet/qlogic/qed/qed_dcbx.c:1230:13-20: WARNING: kzalloc
> > should be used for dcbx_info, instead of kmalloc/memset
> > drivers/net/ethernet/qlogic/qed/qed_dcbx.c:1192:13-20: WARNING: kzalloc
> > should be used for dcbx_info, instead of kmalloc/memset
> > 
> >  Use kzalloc rather than kmalloc followed by memset with 0
[]
> One question the automated script -
> Can't it [relative] easily be upgraded to also have 'Fixes:' as part
> of its message?

It's really not a "fix" as it has no real effect on behavior.

The code is perfectly fine as is really.

It is a code size reduction though.

Another thing with a behavior change and one that would also
reduce code size would be to remove the unnecessary OOM
messages after the allocs.

I'll send a patch for that.
