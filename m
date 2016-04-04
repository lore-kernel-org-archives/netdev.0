From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 0/6] net: dsa: mv88e6131: HW bridging support
 for 6185
Date: Mon, 4 Apr 2016 04:13:13 +0200
Message-ID: <20160404021313.GB22003@lunn.ch>
References: <1459457626-30082-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45528 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022AbcDDCNR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Apr 2016 22:13:17 -0400
Content-Disposition: inline
In-Reply-To: <1459457626-30082-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2016 at 04:53:40PM -0400, Vivien Didelot wrote:
> All packets passing through a switch of the 6185 family are currently all
> directed to the CPU port. This means that port bridging is software driven.
> 
> To enable hardware bridging for this switch family, we need to implement the
> port mapping operations, the FDB operations, and optionally the VLAN operations
> (for 802.1Q and VLAN filtering aware systems).
> 
> However this family only has 256 FDBs indexed by 8-bit identifiers, opposed to
> 4096 FDBs with 12-bit identifiers for other families such as 6352. It also
> doesn't have dedicated FID registers for ATU and VTU operations.
> 
> This patchset fixes these differences, and enable hardware bridging for 6185.

Hi Vivien

I added a test for in chip 6185 bridging, and it worked as expected.

Tested-by: Andrew Lunn <andrew@lunn.ch>

	   Andrew
