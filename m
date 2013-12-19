From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next] netfilter: ipvs: remove the unused variable
Date: Thu, 19 Dec 2013 16:00:29 +0800
Message-ID: <52B2A79D.4060403@huawei.com>
References: <52B258A9.70002@huawei.com> <alpine.LFD.2.11.1312190912090.1749@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <wensong@linux-vs.org>, <horms@verge.net.au>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:64594 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab3LSIBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 03:01:05 -0500
In-Reply-To: <alpine.LFD.2.11.1312190912090.1749@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/19 15:17, Julian Anastasov wrote:
>=20
> 	Hello,
>=20
> On Thu, 19 Dec 2013, Wang Weidong wrote:
>=20
>> when I built the netfilter, I got that:
>> net/netfilter/ipvs/ip_vs_sync.c: In function sync_thread_master=E2=80=
=99:
>> net/netfilter/ipvs/ip_vs_sync.c:1640: warning: unused variable =E2=80=
=98ret=E2=80=99
>=20
> 	There is another patch that we plan to apply but
> due to possible merge conflict it was delayed:
>=20
> http://marc.info/?t=3D138426695600002&r=3D1&w=3D2
> http://marc.info/?t=3D138426469400008&r=3D1&w=3D2
>=20
> 	May be it is time to apply it...
>=20
Ok, Got it.

Regards.
Wang

>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>  net/netfilter/ipvs/ip_vs_sync.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip=
_vs_sync.c
>> index f63c238..d258125 100644
>> --- a/net/netfilter/ipvs/ip_vs_sync.c
>> +++ b/net/netfilter/ipvs/ip_vs_sync.c
>> @@ -1637,7 +1637,7 @@ static int sync_thread_master(void *data)
>>  			continue;
>>  		}
>>  		while (ip_vs_send_sync_msg(tinfo->sock, sb->mesg) < 0) {
>> -			int ret =3D __wait_event_interruptible(*sk_sleep(sk),
>> +			__wait_event_interruptible(*sk_sleep(sk),
>>  						   sock_writeable(sk) ||
>>  						   kthread_should_stop());
>>  			if (unlikely(kthread_should_stop()))
>> --=20
>> 1.7.12
>=20
> Regards
>=20
> --
> Julian Anastasov <ja@ssi.bg>
>=20
