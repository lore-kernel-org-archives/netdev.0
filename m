From: Ivan Frederiks <frederiks@speechpro.com>
Subject: Realtek RTL8102E registers
Date: Tue, 29 Oct 2013 19:05:14 +0400
Message-ID: <526FCEAA.30102@speechpro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux r8169 crew <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spb2.speechpro.com ([149.126.18.58]:59656 "EHLO
	spb2.speechpro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086Ab3J2Pba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 11:31:30 -0400
Received: from [192.168.6.177]
	by mail.stc with esmtp (Exim 4.80.1 (FreeBSD))
	(envelope-from <frederiks@speechpro.com>)
	id 1VbAr5-000Di0-04
	for netdev@vger.kernel.org; Tue, 29 Oct 2013 19:05:15 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I met troubles with RTL8102E operation (you can find detailed
description below). I suppose that those troubles are related to chip
misconfiguration. Maybe you have access to RTL8102E register
description? If yes, would you be so kind to share it with me?

Thank you in advance,

Ivan Frederiks
Embedded developer
Speech Technology Center

Phone: +7-812-331-0665, ext. 6123, 6942
Fax: +7-812-327-9297

P.S.

Issue description:
I'm currently working with a custom motherboard equipped with 2 RTL8102E
ICs and an Intel x86 SOM. SOM runs 32-bit Linux (Arch or Ubuntu).
By default I use r8169 driver. I know that Ethernet link is up (I
checked it with an oscilloscope and I see that RTL8102E link LEDs are
on). In most cases everything works fine. But sometimes driver reports
that link is down. After a power cycle driver reports, that link is up.
When I replace driver with r8101, it always reports that link is up, but
I observe other issues.
