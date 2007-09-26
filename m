From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Userspace network stack and netchannels.
Date: Wed, 26 Sep 2007 17:22:34 +0400
Message-ID: <20070926132234.GA18626@2ka.mipt.ru>
References: <20070925180043.GA16698@2ka.mipt.ru> <1190812125.4257.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55731 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948AbXIZNW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 09:22:57 -0400
Content-Disposition: inline
In-Reply-To: <1190812125.4257.2.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jamal.

On Wed, Sep 26, 2007 at 09:08:45AM -0400, jamal (hadi@cyberus.ca) wrote:
> Those numbers look impressive. How mysterious do things get in SMP?
> Sorry havent had time to stare at the code. How do you measure cpu you
> quoted?

I did not checked how netchannels and userspace stack behaves on SMP
just because I do not have SMP test machines. Getting into account that
netchannels have smaller number of locks (actually only one to queue
skb) compared to sockets, it should not behave worse, but I did not test
that.

CPU usage was obtained via /proc/$pid statistics.

-- 
	Evgeniy Polyakov
