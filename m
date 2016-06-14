From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next v2 10/12] net: dsa: mv88e6xxx: iterate on compatible info
Date: Tue, 14 Jun 2016 18:13:19 -0400
Message-ID: <874m8v1ksg.fsf@ketchup.mtl.sfl>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com> <20160614183153.32327-11-vivien.didelot@savoirfairelinux.com> <20160614214658.GG12832@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:38961 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbcFNWNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 18:13:22 -0400
In-Reply-To: <20160614214658.GG12832@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Tue, Jun 14, 2016 at 02:31:51PM -0400, Vivien Didelot wrote:
>> With legacy probing, we cannot have a compatible info structure. We have
>> to guess it. Instead of using only the first info structure of the info
>> table, iterate over the compatible data.
>> 
>> That way, the legacy code will support new compatible chips with
>> different register access without requiring any code change.
>
> I don't think this is safe when used in combination with multi-chip
> addresses. This code will perform writes on various addresses,
> addresses which could be real registers on a device.
>
> I don't see a need to support guessing. The new binding will work,
> without any guessing. So use that.

OK, I drop this patch and limit the detection in the legacy probing
against the 6085 chip info.

Thanks,

        Vivien
