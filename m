From: Igor Gnatenko <i.gnatenko.brain@gmail.com>
Subject: [REGRESSION] stmmac_platform: Unknown symbol devm_kmalloc (err 0)
Date: Fri, 31 Jul 2015 02:07:26 +0300
Message-ID: <CAFMg4WCm6rs6xMKPiKGmALc45+ne-xUzQgYHH7zOPotQ-iEqjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Maxime Ripard <maxime.ripard@anandra.org>
To: netdev <netdev@vger.kernel.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:33638 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbG3XH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 19:07:28 -0400
Received: by lbbyj8 with SMTP id yj8so36268268lbb.0
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 16:07:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all, stmmac driver doesn't work on cubietruck (and some more
devices like PcDuino3 Nano[0]).

This error comes from converting dwmac-sunxi to platform driver.

stmmac_platform: module license 'unspecified' taints kernel.
Disabling lock debugging due to kernel taint
stmmac_platform: Unknown symbol devm_kmalloc (err 0)
stmmac_platform: Unknown symbol stmmac_suspend (err 0)
stmmac_platform: Unknown symbol platform_get_irq_byname (err 0)
stmmac_platform: Unknown symbol stmmac_dvr_remove (err 0)
stmmac_platform: Unknown symbol platform_get_resource (err 0)
stmmac_platform: Unknown symbol of_get_phy_mode (err 0)
stmmac_platform: Unknown symbol of_property_read_u32_array (err 0)
stmmac_platform: Unknown symbol of_alias_get_id (err 0)
stmmac_platform: Unknown symbol stmmac_resume (err 0)
stmmac_platform: Unknown symbol stmmac_dvr_probe (err 0)

I've filled bugreport with the same info[1]. What info I would provide
to help with fixing this?

[0] https://lists.fedoraproject.org/pipermail/arm/2015-July/009681.html
[1] https://bugzilla.kernel.org/show_bug.cgi?id=102141
-- 
-Igor Gnatenko
