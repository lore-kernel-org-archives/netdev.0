From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] bridge/link: add learning_sync policy flag
Date: Thu, 1 Jan 2015 10:03:54 -0800
Message-ID: <20150101100354.28519a6f@urahara>
References: <1419884407-21998-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:45478 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbbAASEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 13:04:05 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so22938007pab.21
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 10:04:04 -0800 (PST)
In-Reply-To: <1419884407-21998-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Dec 2014 12:20:07 -0800
sfeldma@gmail.com wrote:

> From: Scott Feldman <sfeldma@gmail.com>
> 
> v2:
> 
> Resending now that the dust has cleared in 3.18 on "self" vs. hwmode debate for
> brport settings.  learning_sync is now set/cleared using "self" qualifier on
> brport.
> 
> v1:
> 
> Add 'learned_sync' flag to turn on/off syncing of learned MAC addresses from
> offload device to bridge's FDB.   Flag is be set/cleared on offload device port
> using "self" qualifier:
> 
>   $ sudo bridge link set dev swp1 learning_sync on self
> 
>   $ bridge -d link show dev swp1
>   2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 state forwarding priority 32 cost 2
>       hairpin off guard off root_block off fastleave off learning off flood off
>   2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0
>       learning on learning_sync on
> 
> Adds new IFLA_BRPORT_LEARNED_SYNCED attribute for IFLA_PROTINFO on the SELF
> brport.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied
