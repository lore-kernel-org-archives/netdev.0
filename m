From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: fixed phy -- how do we decide to use this code?
Date: Wed, 15 Apr 2009 20:17:28 +0400
Message-ID: <20090415161728.GA5670@oksana.dev.rtsoft.ru>
References: <B660E2DF-5F6A-4939-9D20-3AB8E7C69EDB@kernel.crashing.org>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Vitaly Bordug <vitb@kernel.crashing.org>,
	Linuxppc-dev Development <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.79.90.228] ([213.79.90.228]:8089 "EHLO
	buildserver.ru.mvista.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754319AbZDOQRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 12:17:30 -0400
Content-Disposition: inline
In-Reply-To: <B660E2DF-5F6A-4939-9D20-3AB8E7C69EDB@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2009 at 10:54:40AM -0500, Kumar Gala wrote:
> Vitaly, Anton
>
> You guys have used this code.. I was wondering how we decide to used the 
> fixed phy vs another phy.  Is this a runtime decision based on something 
> in the device tree or purely at compile time?

It's specified via fixed-link property in the device tree.
The bindings described in Documentation/powerpc/dts-bindings/fsl/tsec.txt.

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
