From: xiakaixu <xiakaixu@huawei.com>
Subject: Re: [PATCH v2 net-next] bpf: s390: Fix build error caused by the
 struct bpf_array member name changed
Date: Tue, 11 Aug 2015 16:42:18 +0800
Message-ID: <55C9B56A.6050301@huawei.com>
References: <1439276026-60789-1-git-send-email-xiakaixu@huawei.com> <55C9B131.50108@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <fengguang.wu@intel.com>, <davem@davemloft.net>,
	<ast@plumgrid.com>, <schwidefsky@de.ibm.com>,
	<heiko.carstens@de.ibm.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <wangnan0@huawei.com>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55C9B131.50108@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2015/8/11 16:24, Daniel Borkmann =E5=86=99=E9=81=93:
> On 08/11/2015 08:53 AM, Kaixu Xia wrote:
>> There is a build error that "'struct bpf_array' has no member
>> named 'prog'" on s390. In commit 2a36f0b, the member 'prog' of
>> struct bpf_array is replaced by 'ptrs'. So this patch fixes it.
>>
>> Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
>=20
> You were also asked to add a proper Fixes tag :
>=20
> Fixes: 2a36f0b92eb6 ("bpf: Make the bpf_prog_array_map more generic")
>=20
> I guess this bug was reported by Fengguang as you have him in Cc ?
>=20
> If that should be the case, then please also add a "Reported-by:" tag
> for his bug report.
>=20
> Code looks good to me.

Thanks for your review. Will follow them in the resubmit version.
>=20
> .
>=20
