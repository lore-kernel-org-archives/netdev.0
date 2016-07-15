From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2016-07-13
Date: Fri, 15 Jul 2016 10:21:23 +0300
Message-ID: <87furbxt70.fsf@kamboji.qca.qualcomm.com>
References: <201607151143.oxJDgbga%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all-JC7UmRfGjtg@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201607151143.oxJDgbga%fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> (kbuild test
	robot's message of "Fri, 15 Jul 2016 11:09:52 +0800")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:

> Hi,
>
> [auto build test ERROR on wireless-drivers-next/master]
> [cannot apply to v4.7-rc7 next-20160714]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Kalle-Valo/pull-request-wireless-drivers-next-2016-07-13/20160714-023750
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git master
> config: sparc64-allmodconfig (attached as .config)
> compiler: sparc64-linux-gnu-gcc (Debian 5.3.1-8) 5.3.1 20160205
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=sparc64 
>
> All error/warnings (new ones prefixed by >>):
>
>    drivers/net/wireless/marvell/mwifiex/scan.c: In function 'mwifiex_cancel_scan':
>>> drivers/net/wireless/marvell/mwifiex/scan.c:2024:12: error: variable 'info' has initializer but incomplete type
>         struct cfg80211_scan_info info = {

The diff was just an example to help Dave fix few conflicts in my pull
request, it was not meant to be applied directly.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
