From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/21] net: dsa: mv88e6xxx: turn into
 monolithic driver
Date: Mon, 09 May 2016 15:00:59 -0400 (EDT)
Message-ID: <20160509.150059.1262002047956591909.davem@davemloft.net>
References: <1462814578-6249-1-git-send-email-vivien.didelot@savoirfairelinux.com>
	<20160509175647.GE10508@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	f.fainelli@gmail.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbcEITBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 15:01:03 -0400
In-Reply-To: <20160509175647.GE10508@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 9 May 2016 19:56:47 +0200

> On Mon, May 09, 2016 at 01:22:37PM -0400, Vivien Didelot wrote:
>> This patchset merges all mv88e6* drivers supported by the shared
>> mv88e6xxx code into a single mv88e6xxx DSA switch driver.
>> 
>> Some flags are added to describe the capabilities of a switch model,
>> such as the presence of a PPU, EEPROM, some old or new registers, etc.
>> 
>> First these flags are used to conditionally support the same set of
>> functions in every driver, then specific driver files are removed in
>> favor of the common mv88e6xxx driver.
>> 
>> Only the merge of driver specific setup code assumes a few differences.
>> If these differences such as frames priorities are really needed for
>> some models, they can easily be brought back in a future patch.
>> 
>> Some inconsistencies might show up, such as the need for
>> MV88E6XXX_FLAG_PPU and MV88E6XXX_FLAG_PPU_ACTIVE flags. But this
>> patchset does not aim to fix them yet. A future patch can do that if
>> they end up being unwanted.
>> 
>> The patchset has been tested on interconnected 88E6352 and 88E6185.
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> 
> I also tested v1, so
> 
> Tested-by: Andrew Lunn <andrew@lunn.ch>

Series applied, thanks everyone.
