From: Frank Li <lznuaa@gmail.com>
Subject: How to reduce Ethernet TX irq number
Date: Tue, 5 Mar 2013 09:47:19 +0800
Message-ID: <CAHrpEqT5+ruCkZx_iFk1JwC1vL_mWyyKHiNY2B8N-rAKRGr_Kg@mail.gmail.com>
References: <CAHrpEqTLm=fQFEKdDfAGo=p2pSxihQVf6=-b4RSUqg0sr9n9YA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:38134 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932290Ab3CEBrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 20:47:21 -0500
Received: by mail-wg0-f47.google.com with SMTP id dr13so4783688wgb.2
        for <netdev@vger.kernel.org>; Mon, 04 Mar 2013 17:47:19 -0800 (PST)
In-Reply-To: <CAHrpEqTLm=fQFEKdDfAGo=p2pSxihQVf6=-b4RSUqg0sr9n9YA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All:
          Recently, I send some patches about put TX handle to NAPI
for freescale FEC.
          But Irq number still huge because we enable irq at each BD.
          Hardware always issue TX irq and irq handle always be called.

          I do test by enable BD irq every 64 packages.
          TX performance can improve huge from 360M to 470M.

          What's correct method to do that?

          Actually, xmit function have return SEND,  stack should
think package already sent when call xmit.
          TX irq handler just free some resource.

best regards
Frank Li
