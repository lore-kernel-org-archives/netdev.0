From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] net: ipv6: Make address flushing on ifdown
 optional
Date: Wed, 14 Oct 2015 05:18:14 -0700 (PDT)
Message-ID: <20151014.051814.801287755321309990.davem@davemloft.net>
References: <1444815241.2154853.409816321.48710CD1@webmail.messagingengine.com>
	<561E29A3.9080101@6wind.com>
	<1444820621.2175377.409880265.37A31E2D@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, dsa@cumulusnetworks.com,
	netdev@vger.kernel.org, hannes@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157AbbJNMCN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 08:02:13 -0400
In-Reply-To: <1444820621.2175377.409880265.37A31E2D@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 14 Oct 2015 13:03:41 +0200

> On Wed, Oct 14, 2015, at 12:08, Nicolas Dichtel wrote:
>> Le 14/10/2015 11:34, Hannes Frederic Sowa a =E9crit :
>> [sni]
>> > This sysctl is on my list to be enabled soon by default by any sys=
temd
>> > based distribution. For that reason, could you maybe remove all th=
e
>> I'm not sure to understand why we add a sysctl then. Or at least, wh=
y the
>> linux
>> default value is different from all standard distrib. I will be like
>> rp_filter :/
>=20
> The difference is that people upgrade (in case of fedora they get a
> .rpmnew file) or install a distribution and don't wonder or have
> assumptions about old behavior. In case companies integrate kernel in
> products/appliances without a way to manage those sysctls we cannot
> simply change them as this would break assumptions for them. I think
> those are two different cases.

The thing that is similar is that people set rp_filter inappropriately
(no end host should have that knob enabled, ever, it's totally
unnecesary).  And the risk here is similar, distribution X will set it
so Y will say "we probably should set it too even though we really
don't understand it fully".

I really hate situations like this.
