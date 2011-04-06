From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] ixgbe: is DCA really that good ?
Date: Wed, 06 Apr 2011 15:44:04 +0200
Message-ID: <1302097444.3209.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>,
	Brattain <ross.b.brattain@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:37160 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755886Ab1DFNoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 09:44:09 -0400
Received: by wwk4 with SMTP id 4so3949887wwk.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 06:44:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys


In a forwarding [or RPS/RFS] setup, why should we populate cpu caches
with full frames content ? We only need first cache line to perform
routing [or RPS/RFS] decision.

-> DCA should be a knob (ethtool ?) that an admin can switch off and on,
port by port, not a CONFIG_IXGBE_DCA thing.

Thanks


