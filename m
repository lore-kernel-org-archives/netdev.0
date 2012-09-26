From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 01/11] netlink: add reference of module in netlink_dump_start
Date: Wed, 26 Sep 2012 15:24:03 +0800
Message-ID: <5062AD93.9080206@cn.fujitsu.com>
References: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com> <1348643247.5093.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	pablo@netfilter.org, steffen.klassert@secunet.com,
	linux-crypto@vger.kernel.org, jengelh@inai.de,
	stephen.hemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348643247.5093.32.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B409=E6=9C=8826=E6=97=A5 15:07, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Wed, 2012-09-26 at 12:52 +0800, Gao feng wrote:
>=20
>> +int netlink_dump_done(struct netlink_callback *cb)
>> +{
>> +	if (cb->module)
>> +		module_put(cb->module);
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL(netlink_dump_done);
>> +
>=20
> No need to test cb->module being not NULL
>=20
>=20
> int netlink_dump_done(struct netlink_callback *cb)
> {
> 	module_put(cb->module);
> 	return 0;
> }
>=20
> Same remark for try_module_get() call
>=20

will fix it in v2 patchset.

thanks Eric.

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
