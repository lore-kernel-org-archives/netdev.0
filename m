From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: Micrel Phy KSZ8031 clock select setting in dts
Date: Mon, 20 Jun 2016 15:56:10 +0300
Message-ID: <8917af7a-82b1-5304-0c35-0efa1f598ba7@cogentembedded.com>
References: <20160617130438.GB6604@graute-opti>
 <bda2a612-37fd-9b73-5aad-6bc62ac2f520@cogentembedded.com>
 <5766f2a8.8f1d1c0a.10cf8.1751@mx.google.com>
 <20160620062101.GL9677@pengutronix.de> <20160620120821.GA19639@graute-opti>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Sascha Hauer <s.hauer@pengutronix.de>, netdev@vger.kernel.org,
	f.fainelli@gmail.com, johan@kernel.org, bth@kamstrup.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:35420 "EHLO
	mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994AbcFTM4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 08:56:23 -0400
Received: by mail-lf0-f51.google.com with SMTP id l188so37061185lfe.2
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 05:56:12 -0700 (PDT)
In-Reply-To: <20160620120821.GA19639@graute-opti>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 6/20/2016 3:08 PM, Oliver Graute wrote:

> thx you both for confirming that. Can you tell me also if the clock
> statement s fine in my dts?
>
> &fec1 {
> 	pinctrl-names = "default";
> 	pinctrl-0 = <&pinctrl_enet1>;
> 	phy-mode = "rmii";
> 	micrel,rmii-reference-clock-select-25-mhz;
> 	clocks,rmii-ref;

    You need:

	clocks = <&your_clock>;
	clock-names = "rmii-ref";

in the PHY node (not the MAC node as you did).

[...]

> Best regards,
>
> Oliver

MBR, Sergei
