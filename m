From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Double free of dst_entry in ipv4_dst_destroy()
Date: Mon, 14 Dec 2015 08:36:26 -0800
Message-ID: <1450110986.8474.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151206132657.Horde.rQvtH4bu51mT83V1RAKxWA1@ltc.linux.ibm.com>
	 <1449435784.25029.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1449453515.25029.54.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1449843809.9768.18.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1449848913.9768.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1449852442.9768.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151214112802.Horde.BK3A-grfQxyYIrszzKdCZg1@ltc.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, predeep@us.ibm.com, mjtarsel@us.ibm.com
To: dwilder@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36220 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbbLNQg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 11:36:28 -0500
Received: by pfbu66 with SMTP id u66so63597051pfb.3
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 08:36:27 -0800 (PST)
In-Reply-To: <20151214112802.Horde.BK3A-grfQxyYIrszzKdCZg1@ltc.linux.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-12-14 at 11:28 -0500, dwilder@us.ibm.com wrote:
> Eric -
> With this patch applied the test ran clean for 2 days.
> 
> Thanks for your help.

Excellent ! 

Thanks a lot David, I will submit it formally with your 'Reported-by'
and 'Tested-by'

I have no idea why this took so long to discover this race.
