From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 2/6] openvswitch: Pass net into ovs_fragment
Date: Thu, 01 Oct 2015 11:03:59 -0500
Message-ID: <87lhbma840.fsf@x220.int.ebiederm.org>
References: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
	<1443648336-31741-2-git-send-email-ebiederm@xmission.com>
	<560CEF75.9050703@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <560CEF75.9050703@6wind.com> (Nicolas Dichtel's message of "Thu,
	1 Oct 2015 10:31:49 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 30/09/2015 23:25, Eric W. Biederman a =C3=A9crit :
>> In preparation for the ipv4 and ipv6 fragmentation code taking a net
>> parameter pass a struct net into ovs_fragment where the v4 and v6
>> fragmentation code is called.
>>
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
> [snip]
>> @@ -748,6 +748,7 @@ static void do_output(struct datapath *dp, struc=
t sk_buff *skb, int out_port,
>>   		if (likely(!mru || (skb->len <=3D mru + ETH_HLEN))) {
>>   			ovs_vport_send(vport, skb);
>>   		} else if (mru <=3D vport->dev->mtu) {
>> +			struct net *net =3D read_pnet(&dp->net);
> nit: add an empty line after variables declaration.
>
>>   			__be16 ethertype =3D key->eth.type;
>>
^^^^^^^^^^^  The empty line is right here, after the second variable
             declaration.

>>   			if (!is_flow_key_valid(key)) {
> [snip]
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
