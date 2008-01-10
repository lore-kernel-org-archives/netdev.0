From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH take2] Re: Nested VLAN causes recursive locking error
Date: Thu, 10 Jan 2008 16:31:22 +0100
Message-ID: <47863A4A.6070303@trash.net>
References: <20080102234107.GA6902@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benny Amorsen <benny+usenet@amorsen.dk>,
	Chuck Ebbert <cebbert@redhat.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57216 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759877AbYAJPfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 10:35:47 -0500
In-Reply-To: <20080102234107.GA6902@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> As a matter of fact I started to doubt it's a real problem: 2 vlan
> headers in the row - is it working?

Yes, apparently some people are using this.

> Anyway, as Patrick pointed, the previous patch was a bit buggy, and
> deeper nesting needs a little more (if it's can work too...). So,
> here is something minimal.
> 
> Patrick, if you think about something else, then of course don't care
> about this patch.

No, this seems fine, thanks. Even better would be a way to get
the last lockdep subclass through lockdep somehow, but I couldn't
find a clean way for this. So I've applied your patch and also
fixed macvlan.


