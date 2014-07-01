From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH RFC V2 2/2] net: qualcomm: new Ethernet over SPI driver
 for QCA7000
Date: Tue, 01 Jul 2014 10:57:45 -0700
Message-ID: <1404237465.14624.9.camel@joe-AO725>
References: <1404232609-4314-1-git-send-email-stefan.wahren@i2se.com>
	 <1404232609-4314-3-git-send-email-stefan.wahren@i2se.com>
	 <20140701174616.GA10927@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stefan Wahren <stefan.wahren@i2se.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	Pawel Moll <Pawel.Moll@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"dave.taht@gmail.com" <dave.taht@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0210.hostedemail.com ([216.40.44.210]:41685 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755253AbaGAR5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 13:57:50 -0400
In-Reply-To: <20140701174616.GA10927@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-01 at 18:46 +0100, Mark Rutland wrote:
> On Tue, Jul 01, 2014 at 05:36:49PM +0100, Stefan Wahren wrote:
> > This patch adds the Ethernet over SPI driver for the
> > Qualcomm QCA7000 HomePlug GreenPHY.
[]
> > +               memcpy(qca->net_dev->dev_addr, mac, ETH_ALEN);
> 
> I believe that it is preferred to write:
> 
> 	ether_addr_copy(qca->net_dev->dev_addr, mac);
> 
> I believe checkpatch has a warning for this.

True, but you have to make sure that both args are
at least __aligned(2) and afaics there's no
guarantee that's true for mac.
