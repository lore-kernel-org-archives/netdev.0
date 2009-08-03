From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 0/5] sky2: Resolve sky2_down/transmit races, lockless transmit
Date: Mon, 3 Aug 2009 20:07:49 +0900
Message-ID: <392fb48f0908030407v6fa32f23pb10ca91ecfb2fd67@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:64469 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572AbZHCLHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 07:07:50 -0400
Received: by fg-out-1718.google.com with SMTP id e21so985886fga.17
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 04:07:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Here is an alternate (and more intrusive) patch set to solve the
transmit during restart issues.

These patches avoid introducing a new state variable by

* reworking the transmit queue to work without locks
* tweaking sky2_down() to avoid invalid tx queue positions being
received in the status queue

Please let me know if this looks better,

thanks,

Mike
