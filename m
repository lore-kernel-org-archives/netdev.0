From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: fix oops in
 rtnl_link_get_slave_info_data_size
Date: Tue, 04 Feb 2014 20:29:26 -0800 (PST)
Message-ID: <20140204.202926.1340649155200205449.davem@davemloft.net>
References: <1391510102.6282.9.camel@nexus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jiri@resnulli.us, netdev@vger.kernel.org, dev@openvswitch.org,
	jesse@nicira.com
To: fernando_b1@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbaBEE31 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 23:29:27 -0500
In-Reply-To: <1391510102.6282.9.camel@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fernando Luis V=E1zquez Cao <fernando_b1@lab.ntt.co.jp>
Date: Tue, 04 Feb 2014 19:35:02 +0900

> We should check whether rtnetlink link operations
> are defined before calling get_slave_size().
>=20
> Without this, the following oops can occur when
> adding a tap device to OVS.
 ...
> Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>

Applied, thanks.
