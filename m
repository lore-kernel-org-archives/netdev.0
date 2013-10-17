From: Peter Schmitt <peter.schmitt82@yahoo.de>
Subject: Re: PROBLEM: GRE forwarding not working with 3.10.x, WCCPv2 and Cisco 7200 Router showing IP0 bad-hlen 4 in tcpdump
Date: Thu, 17 Oct 2013 11:53:10 +0100 (BST)
Message-ID: <1382007190.35868.YahooMailNeo@web172006.mail.ir2.yahoo.com>
References: <1381912513.57737.YahooMailNeo@web172002.mail.ir2.yahoo.com> <1381942996.2045.135.camel@edumazet-glaptop.roam.corp.google.com>
Reply-To: Peter Schmitt <peter.schmitt82@yahoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm31.bullet.mail.ne1.yahoo.com ([98.138.229.24]:48162 "HELO
	nm31.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753343Ab3JQLCE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Oct 2013 07:02:04 -0400
In-Reply-To: <1381942996.2045.135.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


> 
> 3.10 is buggy (for ETH_P_WCCP support I mean), 3.11 has the probable
> fix :
> 
> commit 3d7b46cd20e300bd6989fb1f43d46f1b9645816e
> ("ip_tunnel: push generic protocol handling to ip_tunnel module.")
> 
> The problem is 3.10 do not pull the extra 4 bytes of WCCP
> 
> This is now properly done in iptunnel_pull_header()
> 

First of all, many thanks for your help on this.

I tried to apply the fix to the 3.10.16 sources, as I would like to stay with the long-term line. Unfortunately it does not apply, as there are a lot of dependencies on other patches.

Do you think there will be a fix for the long-time 3.10 kernel line? Or can you guide me on how to apply this fix to the long-term kernel?

Best regards,
Peter
