From: Patrick McHardy <kaber@trash.net>
Subject: Re: linux-next: net tree build warnings
Date: Thu, 26 Mar 2009 14:17:53 +0100
Message-ID: <49CB8081.6050709@trash.net>
References: <20090326173713.ee63b803.sfr@canb.auug.org.au> <1238053819.13879.4.camel@ice-age>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	linux-next@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Leblond <eric@inl.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1238053819.13879.4.camel@ice-age>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Leblond wrote:
> Hi Stephen,
>=20
> Le jeudi 26 mars 2009 =E0 17:37 +1100, Stephen Rothwell a =E9crit :
>> Hi Dave,
>>
>> Today's linux-next build (x86_64 allmodconfig) produced these warnin=
gs:
>>
>> net/bridge/netfilter/ebt_log.c: In function 'ebt_log_init':
>> net/bridge/netfilter/ebt_log.c:230: warning: passing argument 2 of '=
nf_log_register' discards qualifiers from pointer target type
>> net/bridge/netfilter/ebt_log.c: In function 'ebt_log_fini':
>> net/bridge/netfilter/ebt_log.c:236: warning: passing argument 1 of '=
nf_log_unregister' discards qualifiers from pointer target type
>> net/bridge/netfilter/ebt_ulog.c: In function 'ebt_ulog_init':
>> net/bridge/netfilter/ebt_ulog.c:317: warning: passing argument 2 of =
'nf_log_register' discards qualifiers from pointer target type
>> net/bridge/netfilter/ebt_ulog.c: In function 'ebt_ulog_fini':
>> net/bridge/netfilter/ebt_ulog.c:327: warning: passing argument 1 of =
'nf_log_unregister' discards qualifiers from pointer target type
>=20
> Thanks a lot for pointing this. I stupidely forgot to build this modu=
le
> during my testing.

Same here, I seem to have accidentally disabled bridging in my test
builds, sorry.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
