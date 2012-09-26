From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 08/11] crypto: pass crypto_user module to netlink_dump_start
Date: Wed, 26 Sep 2012 15:21:54 +0800
Message-ID: <5062AD12.2000303@cn.fujitsu.com>
References: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com> <1348635140-20225-8-git-send-email-gaofeng@cn.fujitsu.com> <20120926054945.GE4221@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, pablo@netfilter.org,
	linux-crypto@vger.kernel.org, jengelh@inai.de,
	stephen.hemminger@vyatta.com,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:27550 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752575Ab2IZHWH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 03:22:07 -0400
In-Reply-To: <20120926054945.GE4221@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B409=E6=9C=8826=E6=97=A5 13:49, Steffen Klassert =E5=
=86=99=E9=81=93:
> On Wed, Sep 26, 2012 at 12:52:17PM +0800, Gao feng wrote:
>> use proper netlink_dump_control.done and .module to avoid panic.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> Cc: Herbert Xu <herbert@gondor.apana.org.au>
>> ---
>>  crypto/crypto_user.c |    6 +++++-
>>  1 files changed, 5 insertions(+), 1 deletions(-)
>>
>> diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
>> index ba2c611..b5cb32b 100644
>> --- a/crypto/crypto_user.c
>> +++ b/crypto/crypto_user.c
>> @@ -249,6 +249,7 @@ out_err:
>> =20
>>  static int crypto_dump_report_done(struct netlink_callback *cb)
>>  {
>> +	netlink_dump_done(cb);
>>  	return 0;
>=20
> It's probaply better to return the return value of netlink_dump_done(=
)
> instead. Right now, netlink_dump_done() returns 0 in any case,
> but this might change over time.
>=20

Get it, will fix, thanks!
