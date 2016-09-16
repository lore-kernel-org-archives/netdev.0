From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] mwifiex: fix null pointer deference when adapter is null
Date: Fri, 16 Sep 2016 06:56:39 +0300
Message-ID: <87r38ka45k.fsf@kamboji.qca.qualcomm.com>
References: <201609160029.fRGnTGuA%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, kbuild-all-JC7UmRfGjtg@public.gmane.org,
        Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201609160029.fRGnTGuA%fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> (kbuild test
        robot's message of "Fri, 16 Sep 2016 00:29:25 +0800")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:

> url:    https://github.com/0day-ci/linux/commits/Colin-King/mwifiex-fix-null-pointer-deference-when-adapter-is-null/20160915-231625
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git master
> config: x86_64-randconfig-x013-201637 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
>
> All warnings (new ones prefixed by >>):
>
>    drivers/net/wireless/marvell/mwifiex/main.c: In function 'mwifiex_shutdown_sw':
>>> drivers/net/wireless/marvell/mwifiex/main.c:1433:1: warning: label 'exit_remove' defined but not used [-Wunused-label]
>     exit_remove:
>     ^~~~~~~~~~~

Looks like a valid warning to me, so please resend.

-- 
Kalle Valo
