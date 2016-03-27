From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/7] net: dsa: mv88e6xxx: 6185 has only 256 FDBs
Date: Sun, 27 Mar 2016 04:52:25 +0200
Message-ID: <20160327025225.GA15402@lunn.ch>
References: <1459043983-12088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1459043983-12088-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Guenter Roeck <linux@roeck-us.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58213 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480AbcC0Cwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Mar 2016 22:52:30 -0400
Content-Disposition: inline
In-Reply-To: <1459043983-12088-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 26, 2016 at 09:59:38PM -0400, Vivien Didelot wrote:
> The 6185 family has only 256 indexable address databases, while the
> others (such as 6352) have 4095. Explicit and use these maximum values
> in the _mv88e6xxx_fid_new function.

Hi Vivien

I've been looking at the Marvell reference code, in particular, the
function gfdbGetAtuAllCount().

The following device have 16 databases.

( DEV_88E6021 | DEV_88E6060 | DEV_88E6063 |     \
  DEV_FH_VPN |  DEV_88E6083 |  DEV_88E6183 | DEV_88E6093 | DEV_88E6061 )

The following device have 64 databases.
( DEV_88E6065 )

The following devices have 256 databases
( DEV_88E6095_FAMILY | DEV_88E6185_FAMILY )

And the following devices have 4096
( DEV_88E6097_FAMILY | DEV_88E6165_FAMILY | DEV_88E6\
  351_FAMILY| DEV_88E6352_FAMILY )

  Andrew
