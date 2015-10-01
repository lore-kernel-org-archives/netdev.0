From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 1/6] openvswitch: Pass net into ovs_vport_output
Date: Thu, 1 Oct 2015 10:31:56 +0200
Message-ID: <560CEF7C.4070902@6wind.com>
References: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
 <1443648336-31741-1-git-send-email-ebiederm@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443648336-31741-1-git-send-email-ebiederm@xmission.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 30/09/2015 23:25, Eric W. Biederman a =C3=A9crit :
> When struct net starts being passed through the ipv4 and ipv6 fragmen=
t
> routines ovs_vport_output will need to take a net parameter.
> Prepare ovs_vport_output before that is needed and introduce
> ovs_vport_output_skk for the call sites that still need the old
nit: _skk instead of _sk
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
