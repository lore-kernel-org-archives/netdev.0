From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Fri, 29 Oct 2010 11:51:35 -0700
Message-ID: <4CCB17B7.1010908@hp.com>
References: <20101028.112231.232747062.davem@davemloft.net>	<AANLkTinAzvfrRHwW-w-Ppdu7LWd7nGTa4EWP=e6pKV2F@mail.gmail.com>	<1288360820.2092.34.camel@dan> <AANLkTikeaXncdUohUiGF2EkhujYETK5dtyOJASffz2qR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Rosenberg <drosenberg@vsecurity.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	Al Viro <viro@zeniv.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:22615 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809Ab0J2Svj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 14:51:39 -0400
In-Reply-To: <AANLkTikeaXncdUohUiGF2EkhujYETK5dtyOJASffz2qR@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It may be but a paint splatter on the bikeshed, or considered a case of "Doctor! 
Doctor! It hurts when I do this" "Then don't do that!" but elsewhere (not in the 
context of Linux) I've seen mention made of ISV software posting some 
particularly large receives and such - one case I saw was over 1GB, where that 
was tied to the size of a log buffer the creation of which I believe was not 
limited to ~INT_MAX by the application software.

rick jones
