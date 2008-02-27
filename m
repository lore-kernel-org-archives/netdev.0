From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [NET]: Messed multicast lists after dev_mc_sync/unsync
Date: Wed, 27 Feb 2008 09:38:34 +0200 (EET)
Message-ID: <alpine.LRH.1.00.0802270936470.12755@netcore.fi>
References: <47BAEE3B.7020502@trash.net> <20080219.141757.213666958.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:37923 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755770AbYB0HjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 02:39:06 -0500
In-Reply-To: <20080219.141757.213666958.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This seems to have missed 2.6.24.3 (also 2.6.23.17), hopefully the 
next stable will have it.

On Tue, 19 Feb 2008, David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 19 Feb 2008 15:56:59 +0100
>
>>     [NET]: Messed multicast lists after dev_mc_sync/unsync
>>
>>     Commit a0a400d79e3dd7843e7e81baa3ef2957bdc292d0 from you
>>     introduced a new field "da_synced" to struct dev_addr_list that is
>>     not properly initialized to 0. So when any of the current users (8021q,
>>     macvlan, mac80211) calls dev_mc_sync/unsync they mess the address
>>     list for both devices.
>>
>>     The attached patch fixed it for me and avoid future problems.
>>
>>     Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
>>     Signed-off-by: Patrick McHardy <kaber@trash.net>
>
> I've added the headline description of the referenced commit
> to this commit message, and will queue this up to -stable.
>
> Thanks!
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
