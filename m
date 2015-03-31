From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 0/2] ipv6: coding style - comparisons with NULL
Date: Tue, 31 Mar 2015 10:50:29 -0700
Message-ID: <1427824229.10376.38.camel@perches.com>
References: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
	 <1427650577.2715.32.camel@perches.com> <551ACDA4.8000302@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0141.hostedemail.com ([216.40.44.141]:38134 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753128AbbCaRud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 13:50:33 -0400
In-Reply-To: <551ACDA4.8000302@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-31 at 17:39 +0100, Ian Morris wrote:
> IPV6 is a particular interest for me but I'd be happy to cook up a 
> similar patch for IPV4 if there's interest.

I think that'd be nice.

Here's a little script for most of them:

$ ./scripts/checkpatch.pl -f --types=COMPARISON_TO_NULL --strict --fix-inplace net/ipv4/*.[ch]

cheers, Joe
