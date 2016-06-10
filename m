From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 7/8] net: dsa: mv88e6xxx: explicit compatible devices
Date: Fri, 10 Jun 2016 16:26:03 -0400
Message-ID: <87inxgkcys.fsf@ketchup.mtl.sfl>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com> <20160609004456.5441-8-vivien.didelot@savoirfairelinux.com> <20160609021415.GE2227@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:32795 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbcFJU0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 16:26:07 -0400
In-Reply-To: <20160609021415.GE2227@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Andrew Lunn <andrew@lunn.ch> writes:

> On Wed, Jun 08, 2016 at 08:44:55PM -0400, Vivien Didelot wrote:
>> Thanks to the new device probing, we can explicit the exact switch model
>> in the device tree.
>> 
>> Name the driver "mv88e6xxx" and list all its compatible supported chips.
>
> No. This goes against the usual way of doing device tree compatible
> strings. As far as probing goes, all the currently supported switches
> are compatible with 6095. We can at run time determine the specific
> switch model. This list is just a pain to managed, and has no value.
>
> We only need to add a new compatible string when we cannot determine
> at probe time what a switch model is, or we need to read the ID
> register in a different way.

So thinking about this, I might agree that a "compatible" string per
model is not necessary (even though some drivers are doing this, such as
b53), but at least we might want one compatible string per Marvell
switch family. They have different number of ports, different way to
access them via SMI, different way to access the switch ID register.
this information is useful at probe time.

If one string per model is not recommended, I'd suggest one per
family. What do you guys think?

Thanks,

        Vivien
