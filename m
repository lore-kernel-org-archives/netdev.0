From: Adam Osuchowski <adwol@zonk.pl>
Subject: Re: [Bugme-new] [Bug 11655] New: /proc/sys/net/ipv6/conf/all/*
	controls don't work
Date: Mon, 13 Oct 2008 12:13:34 +0200
Message-ID: <20081013101334.6b8b4567@zonk.pl>
References: <bug-11655-10286@http.bugzilla.kernel.org/> <20081002231826.869a1a9e.akpm@linux-foundation.org> <20081013.003239.89070363.davem@davemloft.net>
Reply-To: Adam Osuchowski <adwol@zonk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.ck.polsl.pl ([157.158.1.11]:53938 "EHLO hydra.ck.polsl.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756296AbYJMLH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 07:07:29 -0400
Content-Disposition: inline
In-Reply-To: <20081013.003239.89070363.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Not a bug.
> 
> These "global" setting have to be set to the desired value before the
> device is created.  And it is at creation time that these global
> values are "inherited" by the device.
> 
> Afterwards changes to the global value will not propagate to those
> devices again, because that might override a changed setting made
> by the user.
> 
> It is only newly created devices which get these values.

I understand you are talking about /proc/sys/net/ipv6/conf/default/*
controls. If so, it's ok, but I talked about /proc/sys/net/ipv6/conf/all/*
controls. Documentation/networking/ip-sysctl.txt says:

    conf/default/*:
	    Change the interface-specific default settings.


    conf/all/*:
	    Change all the interface-specific settings.

so what is the difference between default and all in the context of your
statement? In my opinion, it could be understood that default settings
are inherited and those from "all" directory change values for all
current devices.
