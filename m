From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: Micrel Phy KSZ8031 clock select setting in dts
Date: Mon, 20 Jun 2016 15:12:45 +0200
Message-ID: <20160620131245.GS9677@pengutronix.de>
References: <20160617130438.GB6604@graute-opti>
 <bda2a612-37fd-9b73-5aad-6bc62ac2f520@cogentembedded.com>
 <5766f2a8.8f1d1c0a.10cf8.1751@mx.google.com>
 <20160620062101.GL9677@pengutronix.de>
 <20160620120821.GA19639@graute-opti>
 <8917af7a-82b1-5304-0c35-0efa1f598ba7@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, johan@kernel.org,
	bth@kamstrup.dk
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:41965 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752490AbcFTNMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 09:12:51 -0400
Content-Disposition: inline
In-Reply-To: <8917af7a-82b1-5304-0c35-0efa1f598ba7@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 20, 2016 at 03:56:10PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 6/20/2016 3:08 PM, Oliver Graute wrote:
> 
> >thx you both for confirming that. Can you tell me also if the clock
> >statement s fine in my dts?
> >
> >&fec1 {
> >	pinctrl-names = "default";
> >	pinctrl-0 = <&pinctrl_enet1>;
> >	phy-mode = "rmii";
> >	micrel,rmii-reference-clock-select-25-mhz;
> >	clocks,rmii-ref;
> 
>    You need:
> 
> 	clocks = <&your_clock>;
> 	clock-names = "rmii-ref";

With a clock node specified like:

	your_clock: rmii-ref {
		#clock-cells = <0>;
		compatible = "fixed-clock";
		clock-frequency = <50000000>;
	};

(assuming this is a fixed clock which can't be retrieved from elsewhere
in the clock tree)

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
