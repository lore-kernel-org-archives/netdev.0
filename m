From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 5/5] qed*: Add support for read/write of eeprom
Date: Wed, 20 Apr 2016 05:25:22 +0000
Message-ID: <CO2PR11MB0088C92F46E6186231B901DC976D0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1460921195-23352-6-git-send-email-Yuval.Mintz@qlogic.com>
	<20160417.191849.2044093416855662399.davem@davemloft.net>
	<CO2PR11MB0088716755CC57276455ADA4976B0@CO2PR11MB0088.namprd11.prod.outlook.com>,<20160418.000712.473871996964045833.davem@davemloft.net>
 <CO2PR11MB00888E4DBF49BE0A98ACB381976B0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0118.outbound.protection.outlook.com ([157.56.111.118]:17888
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750902AbcDTFZ0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 01:25:26 -0400
In-Reply-To: <CO2PR11MB00888E4DBF49BE0A98ACB381976B0@CO2PR11MB0088.namprd11.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> The third option I see is to completely ditch this, stating that
> >> although We obviously CAN set the non-volatile memory we CAN'T do it
> >> with the regular API, and to move into doing this via some
> >> proprietary API such as debugfs.
> 
> > Why go to debugfs rather than gracefully extending the ethtool stuff
> > to explicitly support what you need?
> 
> Gracefully extend it to where?
> 
> The most I can learn from this is that some adapters are in need of additional
> metadata for doing this sort of stuff.
> The state-machine itself is propriety and I don't think anyone would gain from
> trying to formalize anything else from it.
> If by 'graceful extension' of ethtool API you mean adding an additional field or
> two for metadata - sure, I can do that, I just don't think of it as graceful. ;-)
> 
> And if this is actually the way we want to take this, I would still [don't get upset
> ;-)] argue in favor of overloading the 'magic' field for this purpose, as bnx2x and
> bnxt are already doing.
> Basically if the 'magic' would also contain metadata that could be verified as
> appropriate [I.e., by having valid ranges], it would still fit as a safety measure for
> guaranteeing the correctness of the write request.

Hi Dave,

I'll probably send V2 [relatively] shortly, and it looks like I'll drop this one out
as I don't yet understand the expected direction through which to solve this.

I'd appreciate any suggested pointers here.

Thanks,
Yuval
