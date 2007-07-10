From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: [PATCH 2.6] SoftMAC : fix duplicate display of channel in scan
Date: Tue, 10 Jul 2007 14:25:12 -0500
Message-ID: <4693DD18.1010905@lwfinger.net>
References: <20070710184155.GA6955@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:53218 "EHLO
	mtiwmhc13.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754416AbXGJTZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 15:25:24 -0400
In-Reply-To: <20070710184155.GA6955@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jean,

Jean Tourrilhes wrote:
> 	Hi,
> 
> 	SoftMAC output the channel twice in the scan output. It should
> display frequency and channel, but only once for each.
> --------------------------------------------------------
>           Cell 02 - Address: A2:00:04:XX:XX:XX
>                     ESSID:"TheESSID"
>                     Protocol:IEEE 802.11b
>                     Mode:Ad-Hoc
> ->                  Channel:5
> ->                  Frequency:2.432 GHz (Channel 5)

The frequency output is needed by NetworkManager, which is why I added it. At that time, I thought 
that some tool or other might be scanning the output looking for "Channel:", not "Channel "; 
therefore I left both in. If we are sure that removing the channel-only line will not break 
something, I'll be happy to send your patch upstream.

Larry

