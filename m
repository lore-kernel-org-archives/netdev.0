From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bugme-new] [Bug 11754] New: tlan network driver does not work
Date: Fri, 24 Oct 2008 17:18:35 -0700
Message-ID: <20081024171835.424b75d3@extreme>
References: <bug-11754-10286@http.bugzilla.kernel.org/>
	<200810211634.02138.manfred.scherer.mhm@t-online.de>
	<e6d1cecd0810211540l7182c270l88de14cf18cfcd50@mail.gmail.com>
	<200810240612.13247.manfred.scherer.mhm@t-online.de>
	<20081025000033.GA2967@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Manfred Scherer <manfred.scherer.mhm@t-online.de>,
	Michal Ostrowski <mostrows@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Robert Fitzsimons <robfitz@273k.net>
To: Robert Fitzsimons <robfitz@273k.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42991 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751148AbYJYASm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2008 20:18:42 -0400
In-Reply-To: <20081025000033.GA2967@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Oct 2008 01:00:33 +0100
Robert Fitzsimons <robfitz@273k.net> wrote:

> I've double checked my patch and still think it's correct.  Lets quickly
> review it:
> 
> @@ -360,8 +360,8 @@ TLan_GetSKB( const struct tlan_list_tag *tag)
>  {
>  	unsigned long addr;
>  
> -	addr = tag->buffer[8].address;
> -	addr |= (tag->buffer[9].address << 16) << 16;
> +	addr = tag->buffer[9].address;
> +	addr |= (tag->buffer[8].address << 16) << 16;

There is upper_32_bits(x) and lower_32_bits(x) for this (see kernel.h)
