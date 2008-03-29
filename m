From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] dm9601: Fix multicast hash table handling
Date: Sat, 29 Mar 2008 10:23:24 +0100
Message-ID: <87k5jlc29f.fsf@macbook.be.48ers.dk>
References: <877ifmfsmu.fsf@macbook.be.48ers.dk> <47EDA122.8060400@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.191]:44183 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbYC2Lft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 07:35:49 -0400
Received: by mu-out-0910.google.com with SMTP id i10so1040997mue.5
        for <netdev@vger.kernel.org>; Sat, 29 Mar 2008 04:35:47 -0700 (PDT)
In-Reply-To: <47EDA122.8060400@garzik.org> (Jeff Garzik's message of "Fri\, 28 Mar 2008 21\:53\:38 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Jeff" == Jeff Garzik <jeff@garzik.org> writes:

 Jeff> Peter Korsgaard wrote:
 >> The loop forgot to walk the net->mc_list list, so only the first
 >> multicast address was programmed into the hash table.
 >> ---
 >> Jeff, I would like to get this patch in 2.6.25 if possible.

 Jeff> applied, signed-off-by lines would help...

Thanks, and sorry about that, it seems that I forgot to add the -s
option, that should teach me to not do any work before the morning
coffee ..

-- 
Bye, Peter Korsgaard
