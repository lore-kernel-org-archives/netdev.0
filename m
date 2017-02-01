From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [PATCH net-next 1/2] net: Introduce ife encapsulation module
Date: Wed, 1 Feb 2017 05:57:20 +0000
Message-ID: <DB3PR05MB07644BE44136B484A8B2E42EAC4D0@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1485871024-41836-2-git-send-email-yotamg@mellanox.com>
 <201702010737.nJ8JuLMm%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "kbuild-all@01.org" <kbuild-all@01.org>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20073.outbound.protection.outlook.com ([40.107.2.73]:14896
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751004AbdBAF5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 00:57:24 -0500
In-Reply-To: <201702010737.nJ8JuLMm%fengguang.wu@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: kbuild test robot [mailto:lkp@intel.com]
>Sent: Wednesday, February 01, 2017 1:58 AM
>To: Yotam Gigi <yotamg@mellanox.com>
>Cc: kbuild-all@01.org; jhs@mojatatu.com; davem@davemloft.net;
>netdev@vger.kernel.org; Jiri Pirko <jiri@mellanox.com>; Elad Raz
><eladr@mellanox.com>; Ido Schimmel <idosch@mellanox.com>; Yotam Gigi
><yotamg@mellanox.com>
>Subject: Re: [PATCH net-next 1/2] net: Introduce ife encapsulation module
>
>Hi Yotam,
>
>[auto build test ERROR on net-next/master]
>
>url:
>https://emea01.safelinks.protection.outlook.com/?url=3Dhttps%3A%2F%2Fgithu=
b.co
>m%2F0day-ci%2Flinux%2Fcommits%2FYotam-Gigi%2FExtract-IFE-logic-to-
>module%2F20170131-
>222757&data=3D02%7C01%7Cyotamg%40mellanox.com%7C78ded484c30746e7ecba08
>d44a350e8e%7Ca652971c7d2e4d9ba6a4d149256f461b%7C0%7C0%7C636215039177
>989111&sdata=3DZjfwyvJCJWthy4VSx2Yyteu%2BU3VkVdSIqAPiaCUprqo%3D&reserv
>ed=3D0
>config: alpha-allyesconfig (attached as .config)
>compiler: alpha-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
>reproduce:
>        wget
>https://emea01.safelinks.protection.outlook.com/?url=3Dhttps%3A%2F%2Fgit.k=
ernel
>.org%2Fcgit%2Flinux%2Fkernel%2Fgit%2Fwfg%2Flkp-
>tests.git%2Fplain%2Fsbin%2Fmake.cross&data=3D02%7C01%7Cyotamg%40mellanox.
>com%7C78ded484c30746e7ecba08d44a350e8e%7Ca652971c7d2e4d9ba6a4d149256f
>461b%7C0%7C0%7C636215039177999119&sdata=3DPFLoGWvLTSWuY2e%2F%2F5C%2
>F%2BGlpNGHQgeX3UPXYxrgYqzc%3D&reserved=3D0 -O ~/bin/make.cross
>        chmod +x ~/bin/make.cross
>        # save the attached .config to linux build tree
>        make.cross ARCH=3Dalpha
>
>Note: the linux-review/Yotam-Gigi/Extract-IFE-logic-to-module/20170131-222=
757
>HEAD 236a17de4759e7d4d2927d4ac50329ec788ec655 builds fine.
>      It only hurts bisectibility.
>
>All errors (new ones prefixed by >>):
>
>   net/ife/built-in.o: In function `ife_tlv_meta_encode':
>>> (.text+0x420): multiple definition of `ife_tlv_meta_encode'
>   net/sched/built-in.o:(.text+0x18800): first defined here
>
>---
>0-DAY kernel test infrastructure                Open Source Technology Cen=
ter
>https://emea01.safelinks.protection.outlook.com/?url=3Dhttps%3A%2F%2Flists=
.01.or
>g%2Fpipermail%2Fkbuild-
>all&data=3D02%7C01%7Cyotamg%40mellanox.com%7C78ded484c30746e7ecba08d44a
>350e8e%7Ca652971c7d2e4d9ba6a4d149256f461b%7C0%7C0%7C63621503917799911
>9&sdata=3Dm2yy4YGzOaxrLF%2FjqgxikQ8GELNBj%2F9IlSOlS%2F831tY%3D&reserved
>=3D0                   Intel Corporation

Sorry for that. I will send v2 soon.
