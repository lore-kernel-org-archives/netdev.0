From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 2/2] netxen: support for GbE port settings
Date: Mon, 14 Mar 2011 15:32:40 -0700 (PDT)
Message-ID: <20110314.153240.241445951.davem@davemloft.net>
References: <1299837003-5616-3-git-send-email-amit.salecha@qlogic.com>
	<20110314.151531.233692938.davem@davemloft.net>
	<1300141822.2584.71.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com,
	sony.chacko@qlogic.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51101
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751983Ab1CNWcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:32:02 -0400
In-Reply-To: <1300141822.2584.71.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 14 Mar 2011 22:30:22 +0000

> On Mon, 2011-03-14 at 15:15 -0700, David Miller wrote:
>> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
>> Date: Fri, 11 Mar 2011 01:50:03 -0800
>> 
>> > From: Sony Chacko <sony.chacko@qlogic.com>
>> > 
>> > o Allow setting speed and auto negotiation parameters for GbE ports.
>> > o Log an error message to indicate duplex setting is not supported in
>> >   the hardware currently.
>> > 
>> > Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
>> > Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
>> 
>> The kernel log is not the place to transmit this information.
>> 
>> Please work with Ben Hutchings who is working for ways to report
>> this to the user in the proper location, via ethtool.
> 
> I am?  Well, patches welcome, at least.

You were discussing a scheme, I think with Intel folks, about letting
such changes through then making ethtool re-read the settings and see
which changes were not integrated by the driver.

Then you'd emit a diagnostic from ethtool over stderr to report any
such discrepencies.
