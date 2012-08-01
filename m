From: "Tobias S. Josefowitz" <t.josefowitz@gmail.com>
Subject: binding UDP port 0 with SO_REUSEADDR
Date: Wed, 1 Aug 2012 13:36:49 +0200
Message-ID: <CAEZM=bNdyZoTiGYwNM_3v+ro7dEn0q9aTo4040tBDqDSH3HOXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:64775 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502Ab2HALgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 07:36:50 -0400
Received: by yhmm54 with SMTP id m54so7158811yhm.19
        for <netdev@vger.kernel.org>; Wed, 01 Aug 2012 04:36:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all,

I recently noticed that binding UDP port 0 with SO_REUSEADDR yields
unexpected results for me - the kernel occasionally gives out UDP
ports used by other processes, if they were bound with SO_REUSEADDR,
too.

I did some digging, it seems that
f24d43c07e208372aa3d3bff419afbf43ba87698 introduced this behaviour.
I'm not at all sure if this could/should be called a bug, but I need
to say, it was severly unexpected at my side, and that probably goes
for others, too.

Just bringing this to your attention, I have no suggestions on it whatsoever.

Best,

Tobi
