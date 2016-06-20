From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Micrel Phy KSZ8031 clock select setting in dts
Date: Mon, 20 Jun 2016 14:45:39 +0200
Message-ID: <20160620124539.GB20362@lunn.ch>
References: <20160617130438.GB6604@graute-opti>
 <bda2a612-37fd-9b73-5aad-6bc62ac2f520@cogentembedded.com>
 <5766f2a8.8f1d1c0a.10cf8.1751@mx.google.com>
 <20160620062101.GL9677@pengutronix.de>
 <20160620120821.GA19639@graute-opti>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Sascha Hauer <s.hauer@pengutronix.de>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, f.fainelli@gmail.com, johan@kernel.org,
	bth@kamstrup.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52576 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754556AbcFTMpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2016 08:45:44 -0400
Content-Disposition: inline
In-Reply-To: <20160620120821.GA19639@graute-opti>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> &fec1 {
> 	pinctrl-names = "default";
> 	pinctrl-0 = <&pinctrl_enet1>;
> 	phy-mode = "rmii";
> 	micrel,rmii-reference-clock-select-25-mhz;
> 	clocks,rmii-ref;

You are adding phy properties, not MAC properties. Please put them in
the phy node.

    Andrew
