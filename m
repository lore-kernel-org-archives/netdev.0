From: Szilveszter Ordog <slipszi@gmail.com>
Subject: Problems with tg3 driver after lowering the MTU
Date: Thu, 21 Jan 2010 16:21:47 +0100
Message-ID: <ac67d9131001210721q37a6883eg85430f9564d8e007@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:31842 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428Ab0AUPVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 10:21:49 -0500
Received: by fg-out-1718.google.com with SMTP id 22so81150fge.1
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2010 07:21:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the MTU is lowered (e.g. to 1420) on a tg3-driven interface,
received packets larger than that (e.g. 1500 bytes) are silently
discarded by the driver. Therefore the system doesn't send ICMP
fragmentation-needed packets and the other side doesn't detect this
condition.

Is this a known bug?

slipszi
