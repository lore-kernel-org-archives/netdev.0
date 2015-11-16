From: Adrian Chadd <adrian@freebsd.org>
Subject: What's the expected path to recover from a PHY_HALTED transition?
Date: Mon, 16 Nov 2015 11:29:42 -0800
Message-ID: <CAJ-Vmon_s0o7G84CBOb_V5Y-D-3TMNDq7AOhr9fdiOmxYaFBZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35851 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbbKPT3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 14:29:42 -0500
Received: by iofh3 with SMTP id h3so171049759iof.3
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 11:29:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

I'm debugging an issue on the Broadcom parts (using unimac-mdio.c as
the mdio bus) where i occasionally see MDIO bus read failures, which
causes phy.c to transition the PHY to PHY_HALTED. It stays in this
state until the link is bounced.

So, what's the expectation to handle this and recover from it? is
there some userland piece monitoring things that I'm missing?

Thanks,


-a
