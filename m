From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Is 64k bind patch making bad assumption?
Date: Mon, 2 Feb 2009 21:46:25 +0300
Message-ID: <20090202184625.GA1252@ioremap.net>
References: <20090202103515.60788d0f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <s0mbre@tservice.net.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.ru ([195.178.208.66]:33583 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596AbZBBSqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 13:46:39 -0500
Content-Disposition: inline
In-Reply-To: <20090202103515.60788d0f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen.

On Mon, Feb 02, 2009 at 10:35:15AM -0800, Stephen Hemminger (shemminger@vyatta.com) wrote:
> The patch to allow more that 64k connections is assuming that
> all IP addresses on a machine have the same connectivity and policy.
> I can think of several cases where this is not true:
>   1. Server machine with public IP's for connections and private IP's
>      for backend database connection
>   2. Applications where certain IP's are required for security
>      protocols
>   3. Machines doing policy based routing
> 
> Doesn't this patch change/break this?

I do not think this is related. Patch itself just allows to do what
users ask for. He can do the same with explicit port selection and
reuse option, but bind(0) with the reuse option (i.e. automatic
kernel port selection) was limited.

-- 
	Evgeniy Polyakov
