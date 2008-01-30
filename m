From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [2/2] Remove some unnecessary gotos in established_get_first()
Date: Wed, 30 Jan 2008 09:27:41 +0100
Message-ID: <p73zlun67lu.fsf@bingen.suse.de>
References: <20080130901.138686634@suse.de>
	<20080130080110.35B691B416F@basil.firstfloor.org>
	<200801300925.12397.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:46828 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752920AbYA3I1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 03:27:43 -0500
In-Reply-To: <200801300925.12397.oliver@neukum.org> (Oliver Neukum's message of "Wed\, 30 Jan 2008 09\:25\:12 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oliver@neukum.org> writes:

> Am Mittwoch, 30. Januar 2008 09:01:10 schrieb Andi Kleen:
>> 
>> gcc does not generate different code for return foo vs bar = foo; goto x;
>> x: return bar; So convert it all to direct returns for better readability.
>
> Now suppose somebody needs to change locking. He'll have to convert
> it back. 

Please take a look at the overall /proc/net/tcp logic. Any locking 
change will be a major change to the code flow of the whole family
of funtions.

-Andi
