From: "Mintz, Yuval" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH net-next 5/7] qed*: Set rdma generic functions prefix
Date: Fri, 16 Jun 2017 12:42:35 +0000
Message-ID: <BLUPR0701MB200405BFBC116EE4ADECB6028DC10@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170615202933.20934-6-Yuval.Mintz@cavium.com>
 <201706160519.OPbPzq8J%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "kbuild-all-JC7UmRfGjtg@public.gmane.org" <kbuild-all-JC7UmRfGjtg@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201706160519.OPbPzq8J%fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Hi Michal,
>=20
> [auto build test ERROR on net-next/master]
>=20
> url:    https://github.com/0day-ci/linux/commits/Yuval-Mintz/qed-RDMA-
> and-infrastructure-for-iWARP/20170616-043925
> config: i386-randconfig-x076-06120530 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=3Di386
>=20
> All error/warnings (new ones prefixed by >>):
>=20
>=20
> vim +80 include/linux/qed/qede_rdma.h

... I can't really say I understand the warning from the message.

>=20
> b4d583a63 include/linux/qed/qede_rdma.h Michal Kalderon 2017-06-15  73
> void qede_rdma_dev_event_open(struct qede_dev *dev);
> b4d583a63 include/linux/qed/qede_rdma.h Michal Kalderon 2017-06-15  74
> void qede_rdma_dev_event_close(struct qede_dev *dev);
> b4d583a63 include/linux/qed/qede_rdma.h Michal Kalderon 2017-06-15  75
> void qede_rdma_dev_remove(struct qede_dev *dev);
> b4d583a63 include/linux/qed/qede_rdma.h Michal Kalderon 2017-06-15  76
> void qede_rdma_event_changeaddr(struct qede_dev *edr);
> b4d583a63 include/linux/qed/qede_rdma.h Michal Kalderon 2017-06-15  77
> cee9fbd8e include/linux/qed/qede_roce.h Ram Amrani      2016-10-01  78
> #else
> b4d583a63 include/linux/qed/qede_rdma.h Michal Kalderon 2017-06-15
> @79  static inline int qede_rdma_dev_add(struct qede_dev *dev);
> cee9fbd8e include/linux/qed/qede_roce.h Ram Amrani      2016-10-01 @80  {
> cee9fbd8e include/linux/qed/qede_roce.h Ram Amrani      2016-10-01  81
> 	return 0;
> cee9fbd8e include/linux/qed/qede_roce.h Ram Amrani      2016-10-01  82  }
> cee9fbd8e include/linux/qed/qede_roce.h Ram Amrani      2016-10-01  83
>=20
> :::::: The code at line 80 was first introduced by commit
> :::::: cee9fbd8e2e9e713cd8bf227c6492fd8854de74b qede: Add qedr
> framework
>=20
> :::::: TO: Ram Amrani <Ram.Amrani-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
> :::::: CC: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>=20
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Ce=
nter
> https://lists.01.org/pipermail/kbuild-all                   Intel Corpora=
tion
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
