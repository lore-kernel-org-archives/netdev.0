From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 NEXT 1/1] net: ethtool support to configure number of
 channels
Date: Wed, 13 Apr 2011 11:31:24 -0700 (PDT)
Message-ID: <20110413.113124.59674252.davem@davemloft.net>
References: <1302177522-17815-1-git-send-email-amit.salecha@qlogic.com>
	<1302718921.2873.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, sucheta.chakraborty@qlogic.com,
	anirban.chakraborty@qlogic.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53943
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756741Ab1DMScA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 14:32:00 -0400
In-Reply-To: <1302718921.2873.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 13 Apr 2011 19:22:01 +0100

> On Thu, 2011-04-07 at 04:58 -0700, Amit Kumar Salecha wrote:
>> Ethtool support to configure RX, TX and other channels. combined field
>> in struct ethtool_channels to reflect set of channel (RX, TX or other).
>> Other channel can be link interrupts, SR-IOV coordination etc.
>> 
>> ETHTOOL_GCHANNELS will report max and current number of RX channels,
>> max and current number of TX channels, max and current number of other channel
>> or max and current number of combined channel.
>> 
>> Number of channel can be modify upto max number of channel through
>> ETHTOOL_SCHANNELS command.
>> 
>> Ben Hutchings:
>> o define 'combined' and 'other' types.  Most multiqueue drivers pair up RX and TX
>>   queues so that most channels combine RX and TX work.
>> o Please could you use a kernel-doc comment to describe the structure.
>> 
>> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks everyone.
