From: Zhe Wen <zhewen08@gmail.com>
Subject: Lose AP-STA connection on changing channel width
Date: Sat, 15 Jun 2013 19:01:54 -0700
Message-ID: <CAG=xfvNyr26mBsGxjaVYU9VmSY+CqCE0vK0FW8Q4HAq_eUD6ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:64447 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849Ab3FPCBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jun 2013 22:01:55 -0400
Received: by mail-ie0-f169.google.com with SMTP id 10so4318769ied.14
        for <netdev@vger.kernel.org>; Sat, 15 Jun 2013 19:01:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Developers!

I am trying to change channel type/width (HT20/HT40+) on the both STA
and AP side in a simple system consists of only 1 STA and the AP.

AP is started using hostapd under HT20 and STA thereafter connects to
it using also HT20. But when AP changes its channel type to HT40+
using ieee80211_set_channel_type() and ath9k_hw_set_channel_regs(), it
will lose connection to STA. The way I do channel type change
coordination is: STA sends an action frame to AP, AP sends back ACK
frame and changes its channel type; STA changes its channel type on
receiving the ACK.

I read about this solution
(http://eznemegy.blog.hu/2008/12/14/using_rt2x00_wireless_driver_with_hostapd/fullcommentlist/1)
of hacking into hostapd, which didn't work...

It would be great if you more experienced would love to help me with
this problem!

Thanks in advance!!
Zhe
