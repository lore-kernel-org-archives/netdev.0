From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv4 NEXT 1/1] net: ethtool support to configure number of
 channels
Date: Wed, 13 Apr 2011 19:22:01 +0100
Message-ID: <1302718921.2873.1.camel@bwh-desktop>
References: <1302177522-17815-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, sucheta.chakraborty@qlogic.com,
	anirban.chakraborty@qlogic.com
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38672 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755687Ab1DMSWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 14:22:05 -0400
In-Reply-To: <1302177522-17815-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-07 at 04:58 -0700, Amit Kumar Salecha wrote:
> Ethtool support to configure RX, TX and other channels. combined field
> in struct ethtool_channels to reflect set of channel (RX, TX or other).
> Other channel can be link interrupts, SR-IOV coordination etc.
> 
> ETHTOOL_GCHANNELS will report max and current number of RX channels,
> max and current number of TX channels, max and current number of other channel
> or max and current number of combined channel.
> 
> Number of channel can be modify upto max number of channel through
> ETHTOOL_SCHANNELS command.
> 
> Ben Hutchings:
> o define 'combined' and 'other' types.  Most multiqueue drivers pair up RX and TX
>   queues so that most channels combine RX and TX work.
> o Please could you use a kernel-doc comment to describe the structure.
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Sorry for the delay.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

