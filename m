From: Jean Delvare <jdelvare@suse.de>
Subject: Re: Manual loading of mlx4_en
Date: Tue, 29 Jul 2014 14:06:18 +0200
Message-ID: <1406635578.4498.18.camel@chaos.site>
References: <1406627612.4498.16.camel@chaos.site>
	 <53D7748A.6040800@mellanox.com> <20140729123405.6802fbc4@endymion.delvare>
	 <53D77B26.3070905@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43263 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753004AbaG2MGV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 08:06:21 -0400
In-Reply-To: <53D77B26.3070905@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Tuesday 29 July 2014 =C3=A0 13:44 +0300, Amir Vadai a =C3=A9crit :
> On 7/29/2014 1:34 PM, Jean Delvare wrote:
> > Many thanks for the fast and detailed answer! I'll go backport this
> > commit to kernel 3.12 (and 3.0, hopefully it doesn't have too many
> > dependencies?)
>
> I don't think there is any dependency for that commit. If you're
> backporting it, also take a small fix to it:
> f24f790 net/mlx4_core: Load the Eth driver first

Thanks for the hint. I suppose I should pick 7855bff4 "net/mlx4_core:
Load the IB driver when the device supports IBoE" as well?

--=20
Jean Delvare
SUSE L3 Support
