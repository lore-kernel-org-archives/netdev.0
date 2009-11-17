From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 1/2] ethtool: Add PHY type to ethtool
	get_drvinfo
Date: Tue, 17 Nov 2009 16:33:07 +0000
Message-ID: <1258475587.2732.10.camel@achroite.uk.solarflarecom.com>
References: <20091117161309.11341.9165.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:5979 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbZKQQdG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 11:33:06 -0500
In-Reply-To: <20091117161309.11341.9165.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-17 at 08:13 -0800, Jeff Kirsher wrote:
> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
>=20
> Allow the PHY type to be passed from a driver to ethtool when
> ethtool -i ethX is called.  With newer network cards having SFP
> and SFP+ PHY cages, this information can be useful, especially
> if the NIC supports hot-swapping of the PHY modules.
[...]

I think this information belongs in =EF=BB=BFethtool_cmd, in the port a=
nd/or
transceiver fields.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

