From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH] r8169: Add counters tx_bytes and rx_bytes for ethtool
Date: Wed, 26 May 2010 09:01:31 +0800
Message-ID: <AANLkTilpVg5ucGyWW0VFIod60_V0ZV5bTpUEf_H_AmGX@mail.gmail.com>
References: <AANLkTimRwNqPYh1MgXPhh3hHep7Koc3OJCCroEj_scqg@mail.gmail.com>
	 <20100525195612.GA3344@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:45062 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933285Ab0EZBBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 21:01:32 -0400
Received: by pwi2 with SMTP id 2so1322399pwi.19
        for <netdev@vger.kernel.org>; Tue, 25 May 2010 18:01:32 -0700 (PDT)
In-Reply-To: <20100525195612.GA3344@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois,

>
> If the packets are short enough, replace "_bytes" by "_packets", "_minutes"
> by "_hours" or "_every_day" and the same kind of problem appear.

r8169 has provided 64-bit hardware counters for #packets,
#error_packets, etc. They works fine even on 32-bit systems. What we
really need is just counter rx_bytes and tx_bytes.

>
> You can fix the application at zero cost in the kernel: poll < 34 s and
> update the application counters with the kernel counters increment.

Thanks for you advice.


-- 
--Junchang
