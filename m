From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH iproute2 1/2] utils: add s32 parser
Date: Fri, 25 Nov 2011 18:47:51 +0100
Message-ID: <20111125174751.GA3751@hell>
References: <20111125092451.19e0e9d4@nehalam.linuxnetplumber.net>
 <AE90C24D6B3A694183C094C60CF0A2F6D8AEE6@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:53990 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752474Ab1KYRry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 12:47:54 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AEE6@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Laight | 2011-11-25 17:34:21 [-0000]:

>If you are that worried about numeric overflow (IIRC) you have
>have to check the result for LONG_MIN/MAX (etc) before looking
>at errno.
>
>strtoul() is defined to support -ve values, and I think the
>C rules for conversion between signed and unsigned ints
>DTRT even for non 2's compliment systems.
>
>Some of these bound checks are a waste of time.
>The SUS doesn't require standard utilities to perform them.

David: are you able to fix all conversations functions in utils.c (and add
get_s32). If not I will repost get_s32 with strtol() with the same error check
mechanism as get_* (to be consistent).

Stephen, any other ideas?

Hagen
