From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [REGRESSION] mac80211: IBSS vif queue stopped when started
 after 11s vif
Date: Wed, 29 Mar 2017 09:49:21 +0200
Message-ID: <1490773761.7948.3.camel@sipsolutions.net>
References: <1978424.XTv2Qph05K@bentobox>
         (sfid-20170322_101600_364232_CA0A885F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sven Eckelmann <sven.eckelmann@openmesh.com>,
        linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:41900 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753716AbdC2HtY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 03:49:24 -0400
In-Reply-To: <1978424.XTv2Qph05K@bentobox> (sfid-20170322_101600_364232_CA0A885F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sven,


> But I could be completely wrong about it. It would therefore be
> interesting for me to know who would be responsible to start the
> queues when ieee80211_do_open rejected it for IBSS.

Well, once ieee80211_offchannel_return() is called, that should do the
needful and end up in ieee80211_propagate_queue_wake().

Can you check what the IBSS vif's queues are (vif->hw_queue[...])?

However, I also don't understand the difference between encrypted and
unencrypted here.

johannes
