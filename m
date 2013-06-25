From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: convert lists of macros to
 enumerations
Date: Tue, 25 Jun 2013 16:26:07 -0700 (PDT)
Message-ID: <20130625.162607.2024533380367124753.davem@davemloft.net>
References: <1372024577-6343-1-git-send-email-sakiwit@gmail.com>
	<20130624081414.492ceeb0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sakiwit@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774Ab3FYX0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:26:08 -0400
In-Reply-To: <20130624081414.492ceeb0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 24 Jun 2013 08:14:14 -0700

> On Sun, 23 Jun 2013 15:56:16 -0600
> Jean Sacren <sakiwit@gmail.com> wrote:
> 
>> Use enumerations to replace macros for simpler preprocessing. Map numeric
>> values to enumerators. Where required, prepend the list with an additional
>> enumerator to accommodate the rest.
>> 
>> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> 
> Converting the network based header files is easy and safe as long
> as you test it. Not sure if it is worth the effort.
> 
> But changing the uapi exported header risks breaking applications that
> were doing:
> 
> #ifdef SIOCXXXX
>        do some code to enable that
> #endif
> 
> Since enum values don't show up in the CPP namespace.

Agreed, these patches aren't to be considered seriously.  Too much
potential breakage, and even without that risk I see pretty much
zero value to these changes.
