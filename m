From: didier <did447@gmail.com>
Subject: VLAN GARP triggers a lot of timers if linux compiled with VLAN_8021Q_GVRP
Date: Wed, 29 Sep 2010 02:35:58 +0200
Message-ID: <AANLkTinZ_6+PzAHHc5vaY+H2iX_pf4vsdNsnZ2_N7EDf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55105 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243Ab0I2Af7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 20:35:59 -0400
Received: by fxm14 with SMTP id 14so177984fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 17:35:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In my understanding GARP is using a periodic timer but in net/802/garp.c:

garp_join_timer_arm()

delay = (u64)msecs_to_jiffies(garp_join_time)* net_random() >> 32;
mod_timer(&app->join_timer, jiffies +delay)

Isn't this stuff triggering a *lot* of events?

Didier
