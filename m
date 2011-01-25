From: Yong Zhang <yong.zhang0@gmail.com>
Subject: Re: [PATCH] net: NETCONSOLE_DYNAMIC need CONFIGFS_FS=y
Date: Tue, 25 Jan 2011 16:42:13 +0800
Message-ID: <AANLkTi=4HkAnwGVxypjGZHkwTbBrBvKk4ZOPnHG+SVRS@mail.gmail.com>
References: <1295943748-9699-1-git-send-email-yong.zhang0@gmail.com>
	<20110125083915.GE13618@cr0.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	nab@linux-iscsi.org, "David S. Miller" <davem@davemloft.net>,
	Kevin Hilman <khilman@deeprootsystems.com>
To: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110125083915.GE13618@cr0.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 25, 2011 at 4:39 PM, Am=C3=A9rico Wang <xiyou.wangcong@gmai=
l.com> wrote:
> On Tue, Jan 25, 2011 at 04:22:28PM +0800, Yong Zhang wrote:
>>With CONFIGFS_FS=3Dm && NETCONSOLE_DYNAMIC=3Dy, build error:
>>
>>drivers/built-in.o: In function `netconsole_target_put':
>>build/drivers/net/netconsole.c:133: undefined reference to `config_it=
em_put'
>>drivers/built-in.o: In function `netconsole_target_get':
>>build/drivers/net/netconsole.c:127: undefined reference to `config_it=
em_get'
>>build/drivers/net/netconsole.c:127: undefined reference to `config_it=
em_get'
>>drivers/built-in.o: In function `netconsole_target_put':
>>build/drivers/net/netconsole.c:133: undefined reference to `config_it=
em_put'
>>drivers/built-in.o: In function `drop_netconsole_target':
>>build/drivers/net/netconsole.c:634: undefined reference to `config_it=
em_put'
>>drivers/built-in.o: In function `make_netconsole_target':
>>build/drivers/net/netconsole.c:607: undefined reference to `config_it=
em_init_type_name'
>>drivers/built-in.o: In function `dynamic_netconsole_init':
>>build/drivers/net/netconsole.c:109: undefined reference to `config_gr=
oup_init'
>>build/drivers/net/netconsole.c:111: undefined reference to `configfs_=
register_subsystem'
>>drivers/built-in.o: In function `dynamic_netconsole_exit':
>>build/drivers/net/netconsole.c:116: undefined reference to `configfs_=
unregister_subsystem'
>>
>
> Yeah, this was reported, another way to fix this is "select CONFIGFS_=
=46S".
> Using "select" makes you configure NETCONSOLE_DYNAMIC without caring
> about if you have configured CONFIGFS_FS=3Dy, which seems better.

You mean commit d9f9ab51e55e36379773752ffeaac677b080d469?

Thanks,
Yong

--=20
Only stand for myself
