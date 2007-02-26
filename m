From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: D-Link DGE-528T (r8159) autonegotation of 1000 Mbps link does not work
Date: Mon, 26 Feb 2007 21:02:08 +0100
Message-ID: <20070226200208.GA5384@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.64.0702242214120.1830@qfy-uxvtj8-sro4so00-137.qupc.varg.sv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ShuChen <shuchen@realtek.com.tw>,
	linux-kernel@vger.kernel.org
To: "Petri T. Koistinen" <petri.koistinen@iki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030619AbXBZUDL@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702242214120.1830@qfy-uxvtj8-sro4so00-137.qupc.varg.sv>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please Cc: the maintainer from the MAINTAINERS file.

Petri T. Koistinen <petri.koistinen@iki.fi> :
[...]
> I just brought two D-Link DGE-528T (uses r8159 driver) network adapters
> to have nice 1 Gbps home network between two computers.

- which kernel ?
- dmesg please ?

[...]
> and when I use this cable I only get 10 Mbps connection when connected
> another D-Link DGE-528T.

Try a straight cable between the two D-Link adapters.

[...]
> Do anyone know if there some known bug in auto-negotiation with
> Realtek 8159 chip? (Or is that just wrong cable?)
> 
> Can I force 1000 Mbps link on some other way than giving option to
> insmod? Using /proc or something?

mii-tool or (better) ethtool.

[...]
> What kind of transfer speed you have reached with these cards ? That
> 15 MiB/s is not what I expected.

It smells like fast ethernet. Even my old PII does better than that with
a 8169.

Please send 'mii-tool -vv' and/or ethtool output + vmstat 1 during test.

-- 
Ueimor
