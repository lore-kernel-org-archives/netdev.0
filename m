From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v4 net-next v4 14/14] net: dsa: mv88e6xxx: abstract switch registers accesses
Date: Mon, 20 Jun 2016 13:03:48 -0400
Message-ID: <87oa6vpzbf.fsf@ketchup.mtl.sfl>
References: <20160620160337.2934-1-vivien.didelot@savoirfairelinux.com> <20160620160337.2934-15-vivien.didelot@savoirfairelinux.com> <20160620163053.GE22920@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48094 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754535AbcFTRFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 13:05:42 -0400
In-Reply-To: <20160620163053.GE22920@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew, David,

Andrew Lunn <andrew@lunn.ch> writes:

> On Mon, Jun 20, 2016 at 12:03:37PM -0400, Vivien Didelot wrote:
>> When the SMI address of the switch chip is zero, the chip assumes to be
>> the only one on the SMI master bus and thus responds to all its known
>> SMI devices addresses (port registers, Global2, etc.)
>> 
>> When its SMI address is not zero, some chips (e.g. 88E6352) use an
>> indirect access through two SMI Command and Data registers.
>> 
>> Other models (e.g. 88E6060) using less than 16 internal SMI addresses
>> always use a direct access.
>> 
>> Add a capability flag to describe chips supporting the (indirect)
>> Multi-chip Addressing Mode, and a low-level API to access the registers
>> via SMI.
>> 
>> Other accesses (like Ethernet management frames) may be added later.
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
>
> This series is now ready for merging.

I introduced a warning in that patch by mistake, by printing 'val'
instead of '*val' in a dev_dbg() call...

I respin a v5 with Andrew's tag and the debug printing fixed.

Sorry for the noice...

      Vivien
