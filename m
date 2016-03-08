From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH net 4/4] net: hns: remove useless
 head=ring->next_to_clean
Date: Tue, 08 Mar 2016 10:12:34 +0200
Message-ID: <1457424754.1347.10.camel@linux.intel.com>
References: <1457409147-77086-1-git-send-email-lisheng011@huawei.com>
	 <1457409147-77086-5-git-send-email-lisheng011@huawei.com>
	 <1457421488.1347.5.camel@linux.intel.com> <56DE86FC.8000408@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yisen.zhuang@huawei.com, yankejian@huawei.com,
	xieqianqian@huawei.com, huangdaode@hisilicon.com,
	salil.mehta@huawei.com, netdev@vger.kernel.org,
	haifeng.wei@huawei.com, charles.chenxin@huawei.com,
	linuxarm@huawei.com
To: Lisheng011 <lisheng011@huawei.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47223 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753495AbcCHILu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 03:11:50 -0500
In-Reply-To: <56DE86FC.8000408@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-08 at 16:02 +0800, Lisheng011 wrote:
>=20
> =E5=9C=A8 2016/3/8 15:18, Andy Shevchenko =E5=86=99=E9=81=93:
> >=20
> > On Tue, 2016-03-08 at 11:52 +0800, Lisheng wrote:
> > >=20
> > > From: Qianqian Xie <xieqianqian@huawei.com>
> > >=20
> > > The variable head in hns_nic_tx_fini_pro has read a value,
> > > but the value is not used. The patch will solve it.


> -	/* for hardware bug fixed */
> > This is not good. Explanation is needed why you removed this
> > comment.

> This bug-fixed comment is for the function pointer=C2=A0
> ring_data->fini_process,that is called in function
> hns_nic_common_poll.


> The comment should not be here, so remove it.

Please, add above paragraph to the commit message.

--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
