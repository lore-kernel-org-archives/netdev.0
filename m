From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: mii-tool gigabit support.
Date: Tue, 26 Sep 2006 17:55:34 -0400
Message-ID: <4519A1D6.1050802@pobox.com>
References: <20060926145113.7a6791c8@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dhinds@pcmcia.sourceforge.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:22164 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932297AbWIZVzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 17:55:39 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060926145113.7a6791c8@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The mii-tool utility seems to be abandoned and unmaintained?
> 
> Here is a version that does standard 1000baseT support.
> 	http://developer.osdl.org/shemminger/prototypes/mii-tool.tar.bz2

Not really.  I would rather leave it as-is, and deprecate it in favor of 
ethtool.

I want to keep binary ABI compat, but long term, move away from having 
userspace directly bitbang hardware registers.

	Jeff



