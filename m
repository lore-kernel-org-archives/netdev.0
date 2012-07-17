From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Wed, 18 Jul 2012 00:39:41 +0200
Message-ID: <1342564781.2626.1264.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:39457 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648Ab2GQWjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 18:39:46 -0400
Received: by qadb17 with SMTP id b17so2648701qad.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 15:39:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois

I was wondering why Scatter Gather (NETIF_F_SG) and TX checksum
(NETIF_F_IP_CSUM) were disabled by default on r8169.

Couldnt we enable them by default, maybe for a whitelist of "good"
nics ?

(I found that activating them with ethtool automatically enables GSO,
 and performance with GSO is not good)

Thanks
