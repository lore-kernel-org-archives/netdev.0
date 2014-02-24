From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: Re: Deliver skbs to intermediate interfaces, when using cascaded
 rx-handlers
Date: Mon, 24 Feb 2014 08:28:29 +0100
Message-ID: <20140224072829.GB20295@gmail.com>
References: <20140221130553.GE2870@minipsycho.orion>
 <20140221143114.GC25406@gmail.com>
 <20140221144827.GG2870@minipsycho.orion>
 <20140221.122359.1820499999845408491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:63633 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbaBXH2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 02:28:55 -0500
Received: by mail-la0-f47.google.com with SMTP id y1so757395lam.6
        for <netdev@vger.kernel.org>; Sun, 23 Feb 2014 23:28:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140221.122359.1820499999845408491.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 21, 2014 at 12:23:59PM -0500, David Miller wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Fri, 21 Feb 2014 15:48:27 +0100
> 
> > Would not it be better to make DSA better in order to achieve your goal?
> 
> +1

Ok, message received. I will try to merge the changes back into the
mainline DSA infrastructure. I honestly didn't think it would be of
much interest to anyone.

The original question is really separate from that though. In this
case it is a DSA driver at the bottom, but the question applies to any
case where there are multiple rx-handlers in a cascade
configuration. Wouldn't you agree?

-- 
Thanks
 - wkz
