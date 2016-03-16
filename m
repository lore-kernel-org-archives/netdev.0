From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: fix PHY_RUNNING in phy_state_machine
Date: Thu, 17 Mar 2016 00:05:05 +0100
Message-ID: <20160316230505.GA18161@lunn.ch>
References: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
 <CAGm1_kufFr0SsVwVcABXkL0ABJahiwz4EZ70=ywrtC9Bffbfng@mail.gmail.com>
 <20160316161848.GE2393@lunn.ch>
 <CAGm1_kuMQrECdb6_NpZ83Nm4RFSn6sQMhMK6392PLyaFFxCs1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shaohui ??? <shh.xie@gmail.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Shaohui Xie <Shaohui.Xie@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>, drivshin@allworx.com
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48972 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753137AbcCPXFL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 19:05:11 -0400
Content-Disposition: inline
In-Reply-To: <CAGm1_kuMQrECdb6_NpZ83Nm4RFSn6sQMhMK6392PLyaFFxCs1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 11:23:59PM +0100, Yegor Yefremov wrote:
> Hi Andrew,
> 
> On Wed, Mar 16, 2016 at 5:18 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> > On Wed, Mar 16, 2016 at 04:59:23PM +0100, Yegor Yefremov wrote:
> >
> >> This patch breaks my am335x based board, where one of the CPSW slaves
> >> is connected to IP175D switch chip via RMII interface. Since this
> >> patch packet reception is not working.
> >
> > Hi Yegor
> >
> > Which phy is causing the problem? A PHY inside the switch?
> >
> > Do you have two back to back PHYs between the MAC and the switch, or
> > is the CPSW RMII connected directly to the switch?
> 
> CPSW RMII is connected directly to the switch.

So which PHY is causing you problems?

   Andrew
