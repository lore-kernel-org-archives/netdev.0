From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool: make .get_dump_data() harder to
 misuse by drivers
Date: Tue, 02 Jul 2013 00:16:25 -0700 (PDT)
Message-ID: <20130702.001625.1799445191829949810.davem@davemloft.net>
References: <1372692210-31131-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, anirban.chakraborty@qlogic.com,
	bhutchings@solarflare.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932219Ab3GBHQ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 03:16:27 -0400
In-Reply-To: <1372692210-31131-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Michal Schmidt <mschmidt@redhat.com>
Date: Mon,  1 Jul 2013 17:23:30 +0200

> As the patch "bnx2x: remove zeroing of dump data buffer" showed,
> it is too easy implement .get_dump_data=A0incorrectly in a driver.
>=20
> Let's make sure drivers cannot get confused by userspace requesting
> a too big dump.
>=20
> Also WARN if the driver sets dump->len to something weird and make
> sure the length reported to userspace is the actual length of data
> copied to userspace.
>=20
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied.
