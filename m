From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: About disabling congestion control
Date: Thu, 6 Jan 2011 17:37:58 -0800
Message-ID: <20110106173758.37bfef4d@nehalam>
References: <AANLkTin53drsv18TZ0CPZM7==6G=rK6vScUb=SCQ4-xr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Syed Obaid Amin <obaidasyed@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38238 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754849Ab1AGBiB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 20:38:01 -0500
In-Reply-To: <AANLkTin53drsv18TZ0CPZM7==6G=rK6vScUb=SCQ4-xr@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Jan 2011 20:25:18 -0500
Syed Obaid Amin <obaidasyed@gmail.com> wrote:

> Hey all,
> 
> I am currently working on a socket option to disable the tcp
> congestion control. I think the simplest approach to do this is to
> ignore cwnd before sending out a packet.
> 
> After going through tcp output engine it seems that tcp_cwnd_test is
> the method that decides that how many segments can be sent out on a
> wire. For testing it out, I changed this method so that if no-cc
> option is ON, just return a big constant value. But, it didn't work
> and I am unable to see a burst of pkts. It looks like that I am
> missing something here.
> 
> Any suggestions that what is the right place to look for disabling the
> congestion control ?
> 
> Thanks much!
> 
> Obaid

I assume this is just a local hack experiment; not something you
want to actually submit for other users to use...

The easiest/safest way to do this would be to build/define a new TCP congestion
control type that does nothing.

