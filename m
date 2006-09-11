From: VinX <vincenx@fastwebnet.it>
Subject: Re: tiacx module fail
Date: Mon, 11 Sep 2006 15:13:26 +0200
Message-ID: <450560F6.5030405@fastwebnet.it>
References: <4503F640.3040300@fastwebnet.it> <20060911122541.GA4537@kiopa.cmartin.tk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from aa004msr.fastwebnet.it ([85.18.95.67]:44013 "EHLO
	aa004msr.fastwebnet.it") by vger.kernel.org with ESMTP
	id S1751479AbWIKNQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 09:16:22 -0400
Received: from theconfessional.redirectme.net (23.251.157.101) by aa004msr.fastwebnet.it (7.2.070.1)
        id 44FF059A0029BA88 for netdev@vger.kernel.org; Mon, 11 Sep 2006 15:16:20 +0200
Received: from [192.168.1.144] (unknown [192.168.0.50])
	by theconfessional.redirectme.net (Postfix) with ESMTP id BFF0338E663
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 14:51:24 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <20060911122541.GA4537@kiopa.cmartin.tk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RE-POST...

The dmesg with tiacx module is:
--
<snip>
acx: form factor 0x01 ((mini-)PCI / CardBus), radio type 0x0D (Maxim),
EEPROM version 0x00, uploaded firmware 'Rev 1.9.10.0_A4' (0x01030505)
creating /proc entry driver/acx_eth1
creating /proc entry driver/acx_eth1_diag
creating /proc entry driver/acx_eth1_eeprom
creating /proc entry driver/acx_eth1_phy
acx v0.4.7: net device eth1, driver compiled against wireless extensions 20
<snip>
---
and the dmesg with acx module is:
---
<snip>
acx: form factor 0x01 ((mini-)PCI / CardBus), radio type 0x0D (Maxim),
EEPROM version 0x05, uploaded firmware 'Rev 1.9.10.0_A4' (0x01030505)
creating /proc entry driver/acx_wlan0
creating /proc entry driver/acx_wlan0_diag
creating /proc entry driver/acx_wlan0_eeprom
creating /proc entry driver/acx_wlan0_phy
acx v0.3.35: net device wlan0, driver compiled against wireless
extensions 20
<snip>
---

