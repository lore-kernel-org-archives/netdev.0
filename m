From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next-2.6] net: netif_setup_tc() is static
Date: Fri, 21 Jan 2011 09:54:53 -0800
Message-ID: <4D39C86D.2060209@intel.com>
References: <20110117175542.29543.38690.stgit@jf-dev1-dcblab>	 <20110117180604.29543.38660.stgit@jf-dev1-dcblab>	 <20110119.234132.176672734.davem@davemloft.net> <1295587088.2613.51.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"jarkao2@gmail.com" <jarkao2@gmail.com>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51093 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754042Ab1AURyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 12:54:54 -0500
In-Reply-To: <1295587088.2613.51.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/20/2011 9:18 PM, Eric Dumazet wrote:
> Le mercredi 19 janvier 2011 =C3=A0 23:41 -0800, David Miller a =C3=A9=
crit :
>> From: John Fastabend <john.r.fastabend@intel.com>
>> Date: Mon, 17 Jan 2011 10:06:04 -0800
>>
>>> This patch provides a mechanism for lower layer devices to
>>> steer traffic using skb->priority to tx queues.
>>  ...
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>
>> Applied.
>=20
> Hi John
>=20
> Should netif_setup_tc() be static, or is it meant to be exported
> somehow ?
>=20
> [PATCH net-next-2.6] net: netif_setup_tc() is static
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Acked-by: John Fastabend <john.r.fastabend@intel.com>

Yes this should be static. Thanks Eric!

