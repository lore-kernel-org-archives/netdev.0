From: Peter Schmitt <peter.schmitt82@yahoo.de>
Subject: Re: PROBLEM: GRE forwarding not working with 3.10.x, WCCPv2 and Cisco 7200 Router showing IP0 bad-hlen 4 in tcpdump
Date: Fri, 18 Oct 2013 12:39:16 +0100 (BST)
Message-ID: <1382096356.63655.YahooMailNeo@web172002.mail.ir2.yahoo.com>
References: <1381912513.57737.YahooMailNeo@web172002.mail.ir2.yahoo.com>	 <1381942996.2045.135.camel@edumazet-glaptop.roam.corp.google.com>	 <1382007190.35868.YahooMailNeo@web172006.mail.ir2.yahoo.com> <1382017464.2045.149.camel@edumazet-glaptop.roam.corp.google.com>
Reply-To: Peter Schmitt <peter.schmitt82@yahoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm1.bullet.mail.ird.yahoo.com ([77.238.189.58]:27258 "HELO
	nm1.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751481Ab3JRLjS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 07:39:18 -0400
In-Reply-To: <1382017464.2045.149.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,



> On Thursday, October 17, 2013 3:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2013-10-17 at 11:53 +0100, Peter Schmitt wrote:
>>  Hi,
>> 
>> 
>>  > 
>>  > 3.10 is buggy (for ETH_P_WCCP support I mean), 3.11 has the probable
>>  > fix :
>>  > 
>>  > commit 3d7b46cd20e300bd6989fb1f43d46f1b9645816e
>>  > ("ip_tunnel: push generic protocol handling to ip_tunnel 
> module.")
>>  > 
>>  > The problem is 3.10 do not pull the extra 4 bytes of WCCP
>>  > 
>>  > This is now properly done in iptunnel_pull_header()
>>  > 
>> 
>>  First of all, many thanks for your help on this.
>> 
>>  I tried to apply the fix to the 3.10.16 sources, as I would like to
>>  stay with the long-term line. Unfortunately it does not apply, as
>>  there are a lot of dependencies on other patches.
>> 
>>  Do you think there will be a fix for the long-time 3.10 kernel line?
>>  Or can you guide me on how to apply this fix to the long-term kernel?
> 
> 3.10 is right in the middle of GRE refactoring, and many bugs are in it.
> 
> It might be very painful to get a complete list of patches to backport.

thanks again. Yes I saw that there were lots of changes.

Do you think there will be a fix for all the 3.10.x stable long term kernel users? Many of them might not be able to use some newer kernel easily or will this be a "won't fix"?

Best regards,
Peter
