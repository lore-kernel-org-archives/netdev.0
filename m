From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mac80211: reject ToDS broadcast data frames
Date: Thu, 20 Apr 2017 15:38:09 -0400 (EDT)
Message-ID: <20170420.153809.763038513182171279.davem@davemloft.net>
References: <20170420193216.17087-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947066AbdDTTiM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 15:38:12 -0400
In-Reply-To: <20170420193216.17087-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 20 Apr 2017 21:32:16 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> AP/AP_VLAN modes don't accept any real 802.11 multicast data
> frames, but since they do need to accept broadcast management
> frames the same is currently permitted for data frames. This
> opens a security problem because such frames would be decrypted
> with the GTK, and could even contain unicast L3 frames.
> 
> Since the spec says that ToDS frames must always have the BSSID
> as the RA (addr1), reject any other data frames.
> 
> The problem was originally reported in "Predicting, Decrypting,
> and Abusing WPA2/802.11 Group Keys" at usenix
> https://www.usenix.org/conference/usenixsecurity16/technical-sessions/presentation/vanhoef
> and brought to my attention by Jouni.
> 
> Cc: stable@vger.kernel.org
> Reported-by: Jouni Malinen <j@w1.fi>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> --
> Dave, I didn't want to send you a new pull request for a single
> commit yet again - can you apply this one patch as is?

Sure, done.
