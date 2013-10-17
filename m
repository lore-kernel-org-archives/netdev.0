From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: GRE forwarding not working with 3.10.x, WCCPv2 and
 Cisco 7200 Router showing IP0 bad-hlen 4 in tcpdump
Date: Thu, 17 Oct 2013 06:44:24 -0700
Message-ID: <1382017464.2045.149.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381912513.57737.YahooMailNeo@web172002.mail.ir2.yahoo.com>
	 <1381942996.2045.135.camel@edumazet-glaptop.roam.corp.google.com>
	 <1382007190.35868.YahooMailNeo@web172006.mail.ir2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: Peter Schmitt <peter.schmitt82@yahoo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:65095 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755305Ab3JQNo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 09:44:26 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp16so2337055pbb.28
        for <netdev@vger.kernel.org>; Thu, 17 Oct 2013 06:44:25 -0700 (PDT)
In-Reply-To: <1382007190.35868.YahooMailNeo@web172006.mail.ir2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-17 at 11:53 +0100, Peter Schmitt wrote:
> Hi,
> 
> 
> > 
> > 3.10 is buggy (for ETH_P_WCCP support I mean), 3.11 has the probable
> > fix :
> > 
> > commit 3d7b46cd20e300bd6989fb1f43d46f1b9645816e
> > ("ip_tunnel: push generic protocol handling to ip_tunnel module.")
> > 
> > The problem is 3.10 do not pull the extra 4 bytes of WCCP
> > 
> > This is now properly done in iptunnel_pull_header()
> > 
> 
> First of all, many thanks for your help on this.
> 
> I tried to apply the fix to the 3.10.16 sources, as I would like to
> stay with the long-term line. Unfortunately it does not apply, as
> there are a lot of dependencies on other patches.
> 
> Do you think there will be a fix for the long-time 3.10 kernel line?
> Or can you guide me on how to apply this fix to the long-term kernel?

3.10 is right in the middle of GRE refactoring, and many bugs are in it.

It might be very painful to get a complete list of patches to backport.
