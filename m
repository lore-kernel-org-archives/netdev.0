From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] ptp: increase the maximum number of clocks
Date: Sat, 23 Mar 2013 18:59:15 +0100
Message-ID: <20130323175915.GA3036@netboy.at.omicron.at>
References: <d219aa87bd5b3e2fa42449720d845a7110f642f0.1363893841.git.jbenc@redhat.com>
 <20130321.172017.1499060411785395307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbenc@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:37955 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707Ab3CWSFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 14:05:49 -0400
Received: by mail-ee0-f45.google.com with SMTP id b57so2635050eek.4
        for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 11:05:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130321.172017.1499060411785395307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 21, 2013 at 05:20:17PM -0400, David Miller wrote:
> 
> This really needs to be dynamic, and it shows what a bad idea it was
> to use character drivers for this which introduces arbitrary device
> arity limitations.

If a clock is not a character device, what then should it be? Network
interface?  Block device?  sysfs apparition?

IIRC, the RTCs appear as char devices. In any case, we are better off
with char devices than with an enumeration of SYSV clock IDs.
 
> I want to see a better solution to this problem than just bumping this
> limit arbitrarily every once in a while.

Jiri, do you want to work on making the number of clocks essentially
unlimited? If not, I can take a look at this, but not right away.

Thanks,
Richard
