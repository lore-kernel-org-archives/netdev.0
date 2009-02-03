From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC] netlink broadcast return value
Date: Tue, 03 Feb 2009 11:07:18 +0100
Message-ID: <49881756.8000700@netfilter.org>
References: <4985A4C5.4050908@netfilter.org> <200902021435.09941.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59245 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750966AbZBCKHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2009 05:07:39 -0500
In-Reply-To: <200902021435.09941.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi I=C3=B1aky,

Inaky Perez-Gonzalez wrote:
> On Sunday 01 February 2009, Pablo Neira Ayuso wrote:
>=20
>> =3D=3D genlmsg_multicast (calls nlmsg_multicast) =3D=3D
>> net/netlink/genetlink.c			: ignores return value
>> drivers/acpi/event.c			: printk error
>> fs/dquot.c				: printk error (if err !=3D -ESRCH)
>> net/wireless/nl80211.c			: ignores return value
>>
>> In short, I think that the change that I'm proposing would also requ=
ire
>> to fix some netlink_broadcast() clients to skip ENOBUFS errors: they=
 are
>> not meaningful for them since they assume that Netlink is unreliable=
 and
>> so the return value does not provide any useful information.
>=20
> You are missing a few callers in net/wimax. Which kernel version did =
you
> do the analysis on?

I was using Patrick's tree (nf-2.6.git) which did not contain net/wimax
yet. I'm going to re-check against David's tree and let you know.

--=20
"Los honestos son inadaptados sociales" -- Les Luthiers
