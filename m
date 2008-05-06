From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ariadne: use netstats in net_device structure (fwd)
Date: Tue, 6 May 2008 22:30:15 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0805062230070.6341@anakin>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yorgi.telenet-ops.be ([195.130.133.69]:57290 "EHLO
	yorgi.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451AbYEFUbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 16:31:24 -0400
Received: from harold.telenet-ops.be (harold.telenet-ops.be [195.130.133.65])
	by yorgi.telenet-ops.be (Postfix) with ESMTP id DA2F26807A7
	for <netdev@vger.kernel.org>; Tue,  6 May 2008 22:30:49 +0200 (CEST)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by harold.telenet-ops.be (Postfix) with SMTP id 5B18F30065
	for <netdev@vger.kernel.org>; Tue,  6 May 2008 22:30:18 +0200 (CEST)
Received: from anakin.of.borg (78-21-204-88.access.telenet.be [78.21.204.88])
	by harold.telenet-ops.be (Postfix) with ESMTP id 4D33030052
	for <netdev@vger.kernel.org>; Tue,  6 May 2008 22:30:16 +0200 (CEST)
Received: from anakin.of.borg (localhost [127.0.0.1])
	by anakin.of.borg (8.14.2/8.14.2/Debian-4) with ESMTP id m46KUGhE013401
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 6 May 2008 22:30:16 +0200
Received: from localhost (geert@localhost)
	by anakin.of.borg (8.14.2/8.14.2/Submit) with ESMTP id m46KUGgb013398
	for <netdev@vger.kernel.org>; Tue, 6 May 2008 22:30:16 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---------- Forwarded message ----------
Date: Tue, 6 May 2008 09:28:14 +0200 (CEST)
From: Geert Uytterhoeven <geert@linux-m68k.org>
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Cc: Linux/m68k <linux-m68k@vger.kernel.org>
Subject: Re: [PATCH] ariadne: use netstats in net_device structure

On Tue, 6 May 2008, Paulius Zaleckas wrote:
> Use net_device_stats from net_device structure instead of local.
> 
> Haven't tried to compile it. Need ack from m68k people!
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

Thanks!

I slightly changed your patch to remove 2 instances of `priv' that are
no longer used.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
--
To unsubscribe from this list: send the line "unsubscribe linux-m68k" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
