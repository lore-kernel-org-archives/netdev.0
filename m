From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] net: dsa: mv88e6131: HW bridging
 support for 6185
Date: Mon, 04 Apr 2016 21:31:57 -0400 (EDT)
Message-ID: <20160404.213157.1584495549318748510.davem@davemloft.net>
References: <1459457626-30082-1-git-send-email-vivien.didelot@savoirfairelinux.com>
	<20160404021313.GB22003@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbcDEBcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 21:32:00 -0400
In-Reply-To: <20160404021313.GB22003@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 4 Apr 2016 04:13:13 +0200

> On Thu, Mar 31, 2016 at 04:53:40PM -0400, Vivien Didelot wrote:
>> All packets passing through a switch of the 6185 family are currently all
>> directed to the CPU port. This means that port bridging is software driven.
>> 
>> To enable hardware bridging for this switch family, we need to implement the
>> port mapping operations, the FDB operations, and optionally the VLAN operations
>> (for 802.1Q and VLAN filtering aware systems).
>> 
>> However this family only has 256 FDBs indexed by 8-bit identifiers, opposed to
>> 4096 FDBs with 12-bit identifiers for other families such as 6352. It also
>> doesn't have dedicated FID registers for ATU and VTU operations.
>> 
>> This patchset fixes these differences, and enable hardware bridging for 6185.
> 
> Hi Vivien
> 
> I added a test for in chip 6185 bridging, and it worked as expected.
> 
> Tested-by: Andrew Lunn <andrew@lunn.ch>

Series applied to net-next, thanks.
