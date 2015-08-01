From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Add ff_dup wich disable advertise on full duplex
Date: Sat, 01 Aug 2015 16:19:05 -0700 (PDT)
Message-ID: <20150801.161905.2117706264648324224.davem@davemloft.net>
References: <1438449621-3061-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: corcodel.marian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbbHAXTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Aug 2015 19:19:08 -0400
In-Reply-To: <1438449621-3061-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <corcodel.marian@gmail.com>
Date: Sat,  1 Aug 2015 20:20:21 +0300

>    Add parameter ff_dup wich disable advertise 10/100Mbs
>  duplex full   for card wich start on low speed on full duplex.Verry strange with this patch
>  First insert module with ff_dup=1 link is good , unload module, load module wo parameter ff_dup
>  and is full duplex and full speed on RTL_GIGA_MAC_VER_09.  
> 
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

This patch, like all of your other patches, is not acceptable.

First of all, such module parameters are strongly discouraged.

Instead, such things should be controlled by portable, generic, run
time configurations mechanisms such as ethtool.

Furthermore, you are not explaining sufficiently why this configuration
option is really needed and in exactly what circumstances they would
be used.

I want to _STRONGLY_ impress upon you how much time and effort is
seemingly being wasted on your poorly thought out and formatted
patches.

If this continues do not be surprised if you find it hard for people
willing to look at your submissions at all.  You need to start making
clean proper submissions soon.
