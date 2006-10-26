From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] tcp: setsockopt congestion control autoload
Date: Thu, 26 Oct 2006 09:22:53 +0400
Message-ID: <20061026052253.GA10188@2ka.mipt.ru>
References: <20061025110843.0cbd18a7@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:14253 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1423410AbWJZFYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 01:24:00 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061025110843.0cbd18a7@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 25, 2006 at 11:08:43AM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> If user asks for a congestion control type with setsockopt() then it
> may be available as a module not included in the kernel already. 
> It should be autoloaded if needed.  This is done already when
> the default selection is change with sysctl, but not when application
> requests via sysctl.
> 
> Only reservation is are there any bad security implications from this?

What if system is badly configured, so it is possible to load malicious
module by kernel?

-- 
	Evgeniy Polyakov
