From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next V4] bond: have random dev address by default
 instead of zeroes
Date: Wed, 30 Jan 2013 15:34:12 -0500 (EST)
Message-ID: <20130130.153412.790821387539992014.davem@davemloft.net>
References: <1359540491-768-1-git-send-email-jiri@resnulli.us>
	<17070.1359573593@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jiri@resnulli.us, netdev@vger.kernel.org, andy@greyhouse.net,
	stephen@networkplumber.org, psimerda@redhat.com, dcbw@redhat.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502Ab3A3UeT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 15:34:19 -0500
In-Reply-To: <17070.1359573593@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jay Vosburgh <fubar@us.ibm.com>
Date: Wed, 30 Jan 2013 11:19:53 -0800

> Jiri Pirko <jiri@resnulli.us> wrote:
>=20
>>Makes more sense to have randomly generated address by default than t=
o
>>have all zeroes. It also allows user to for example put the bond into
>>bridge without need to have any slaves in it.
>>
>>Also note that this changes only behaviour of bonds with no slaves. O=
nce
>>the first slave device is enslaved, its address will be used (no chan=
ge
>>here).
>>
>>Also, fix dev_assign_type values on the way.
>>
>>Reported-by: Pavel =A6imerda <psimerda@redhat.com>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>=20
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks.
