From: "Mintz, Yuval" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH net-next 4/7] qed*: Rename qede_roce.[ch]
Date: Fri, 16 Jun 2017 12:41:15 +0000
Message-ID: <BLUPR0701MB2004F40778215AD277D4FF348DC10@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170615202933.20934-5-Yuval.Mintz@cavium.com>
 <201706160552.EYIdXcuM%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "kbuild-all-JC7UmRfGjtg@public.gmane.org" <kbuild-all-JC7UmRfGjtg@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201706160552.EYIdXcuM%fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>    In file included from drivers/net//ethernet/qlogic/qede/qede.h:43:0,
>                     from drivers/net//ethernet/qlogic/qede/qede_ptp.h:38,
>                     from drivers/net//ethernet/qlogic/qede/qede_fp.c:43:
> >> include/linux/qed/qede_rdma.h:57:12: warning: 'struct pci_dev' declare=
d
> inside parameter list [enabled by default]
> >> include/linux/qed/qede_rdma.h:57:12: warning: its scope is only this
> definition or declaration, which is probably not what you want [enabled b=
y
> default]

This patch is merely renaming qede_roce.h -> qede_rdma.h.
I guess the kbuild test robot got better scripts than the time we've added =
qede_rdma.h,
or else it would have catched the fact there are no inclusion since then.

Dave - given this is an existing warning exposed due to a rename [and not s=
omething
that actually got introduced in this patch], do you want us to fix it via v=
2 of this series?
Or send a fix for it later?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
