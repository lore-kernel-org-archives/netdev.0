From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCHv4 NEXT 1/1] net: ethtool support to configure number of
 channels
Date: Wed, 13 Apr 2011 13:03:17 +0100
Message-ID: <1302696197.5282.612.camel@localhost>
References: <1302177522-17815-1-git-send-email-amit.salecha@qlogic.com>
	 <99737F4847ED0A48AECC9F4A1974A4B80FD1384031@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:55205 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754721Ab1DMMDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 08:03:21 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80FD1384031@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-13 at 04:45 -0500, Amit Salecha wrote:
> > Ethtool support to configure RX, TX and other channels. combined field
> > in struct ethtool_channels to reflect set of channel (RX, TX or other).
> > Other channel can be link interrupts, SR-IOV coordination etc.
> >
> > ETHTOOL_GCHANNELS will report max and current number of RX channels,
> > max and current number of TX channels, max and current number of other
> > channel
> > or max and current number of combined channel.
> >
> > Number of channel can be modify upto max number of channel through
> > ETHTOOL_SCHANNELS command.
> >
> > Ben Hutchings:
> > o define 'combined' and 'other' types.  Most multiqueue drivers pair up
> > RX and TX
> >   queues so that most channels combine RX and TX work.
> > o Please could you use a kernel-doc comment to describe the structure.
> >
> > Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> 
> Neither I see this patch in http://patchwork.ozlabs.org/project/netdev/list/ nor any comment.
> Just curious, is this patch discarded along with my other garbage patches ?

It's marked as 'deferred'; not sure what that means:

http://patchwork.ozlabs.org/patch/90166/

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

