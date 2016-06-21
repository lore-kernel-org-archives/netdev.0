From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next v5 00/14] net: dsa: mv88e6xxx: probe
 compatible
Date: Tue, 21 Jun 2016 04:05:55 -0400 (EDT)
Message-ID: <20160621.040555.499804482075482409.davem@davemloft.net>
References: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch, f.fainelli@gmail.com,
	ben.dooks@codethink.co.uk, sergei.shtylyov@cogentembedded.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34146 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932858AbcFUIGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 04:06:36 -0400
In-Reply-To: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 20 Jun 2016 13:13:57 -0400

> This patchset factorizes the legacy and new SMI probing and abstracts
> the switch register accesses. This simplifies adding support for new
> chips or alternative register accesses.
> 
> This will allow us to use a compatible chip info to describe how to
> access the SMI device and its switch ID register at probe time.
> 
> For the legacy probe, we fix the compatible info to 88E6085. For the
> MDIO probe, we will use the compatible info from the device node data.
> 
> All patches are reviewed.

Series applied, thanks Vivien.
