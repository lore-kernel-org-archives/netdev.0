From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: question on ndo_start_xmit()
Date: Sun, 2 Sep 2012 17:46:05 +0100
Message-ID: <1346604365.7787.0.camel@deadeye.wl.decadent.org.uk>
References: <6485890.uF7kvdezU7@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36802 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754128Ab2IBQqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 12:46:13 -0400
In-Reply-To: <6485890.uF7kvdezU7@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-09-02 at 15:39 +0200, Oliver Neukum wrote:
> Hi,
> 
> is it possible that ndo_start_xmit is called with skb==NULL ?

Only through a bug in the caller.  It is not a valid argument.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
