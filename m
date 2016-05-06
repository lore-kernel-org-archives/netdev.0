From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 19/20] net: dsa: mv88e6xxx: factorize tag
 protocol
Date: Fri, 6 May 2016 03:09:49 +0200
Message-ID: <20160506010949.GM7972@lunn.ch>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1462488064-1841-20-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58037 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754196AbcEFBJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 21:09:52 -0400
Content-Disposition: inline
In-Reply-To: <1462488064-1841-20-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2016 at 06:41:03PM -0400, Vivien Didelot wrote:
> 6131 is the only driver to set the tag protocol to DSA_TAG_PROTO_DSA.
> Since it works fine with DSA_TAG_PROTO_EDSA, change its value, like all
> other mv88e6xxx drivers.

Hi Vivien

You might as well remove net/dsa/tag_dsa.c as well, since it is now
unused. Please do that as a separate patch.

	Andrew
