From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: [PATCH net-next] igmp: hash a hash table to speedup
 ip_check_mc_rcu()
Date: Fri, 7 Jun 2013 12:33:19 -0500
Message-ID: <20130607173319.GC2995@sbohrermbp13-local.rgmadvisors.com>
References: <20130605175724.GA2576@sbohrermbp13-local.rgmadvisors.com>
 <1370455997.24311.290.camel@edumazet-glaptop>
 <20130605203253.GB2576@sbohrermbp13-local.rgmadvisors.com>
 <1370465535.24311.304.camel@edumazet-glaptop>
 <1370565301.24311.396.camel@edumazet-glaptop>
 <20130607144833.GB2995@sbohrermbp13-local.rgmadvisors.com>
 <1370620137.24311.433.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:40619 "EHLO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754981Ab3FGRdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 13:33:23 -0400
Received: by mail-ob0-f180.google.com with SMTP id eh20so7061916obb.11
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 10:33:22 -0700 (PDT)
In-Reply-To: <1370620137.24311.433.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 07, 2013 at 08:48:57AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> After IP route cache removal, multicast applications using
> a lot of multicast addresses hit a O(N) behavior in ip_check_mc_rcu()
> 
> Add a per in_device hash table to get faster lookup.
> 
> This hash table is created only if the number of items in mc_list is
> above 4.
> 
> Reported-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> Shawn, this is a different version from the v0.
> so please test it and add your "Tested-by: " if OK, thanks.

Patch works great thanks!

Tested-by: Shawn Bohrer <sbohrer@rgmadvisors.com>

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
