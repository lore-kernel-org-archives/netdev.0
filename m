From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: batostr() function
Date: Tue, 08 May 2012 16:25:08 +0200
Message-ID: <1336487108.4320.2.camel@jlt3.sipsolutions.net>
References: <1336391383.4325.24.camel@jlt3.sipsolutions.net>
	 <CANq1E4QW4vSn_r9C=rirShE+-eyPjRX+b5tpC+mx69Hs6aEYqQ@mail.gmail.com>
	 (sfid-20120508_153110_439793_D7D64B69)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: David Herrmann <dh.herrmann@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:56888 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015Ab2EHOZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 10:25:11 -0400
In-Reply-To: <CANq1E4QW4vSn_r9C=rirShE+-eyPjRX+b5tpC+mx69Hs6aEYqQ@mail.gmail.com> (sfid-20120508_153110_439793_D7D64B69)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-08 at 15:30 +0200, David Herrmann wrote:
> Hi Johannes
> 
> On Mon, May 7, 2012 at 1:49 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
> > Really? 2 static buffers that are used alternately based on a static
> > variable? How can that possibly be thread-safe? That may work in very
> > restricted scenarios, but ...
> 
> Looking at "git blame" it seems the whole function is still from
> linux-2.4. Looks like no-one ever noticed. I've sent a patchset fixing
> it, thanks.

I was thinking you could use %pM, but it seems BT addresses are stored
the wrong way around for some reason ...

johannes
