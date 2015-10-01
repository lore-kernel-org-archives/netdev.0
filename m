From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 2/6] openvswitch: Pass net into ovs_fragment
Date: Fri, 2 Oct 2015 00:14:57 +0200
Message-ID: <560DB061.5070909@6wind.com>
References: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
 <1443648336-31741-2-git-send-email-ebiederm@xmission.com>
 <560CEF75.9050703@6wind.com> <87lhbma840.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87lhbma840.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 01/10/2015 18:03, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>> Le 30/09/2015 23:25, Eric W. Biederman a =C3=A9crit :
[snip]
>>> +			struct net *net =3D read_pnet(&dp->net);
>> nit: add an empty line after variables declaration.
>>
>>>    			__be16 ethertype =3D key->eth.type;
>>>
> ^^^^^^^^^^^  The empty line is right here, after the second variable
>               declaration.
Rooh ... I need glasses ;-)

Sorry for the noise.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
