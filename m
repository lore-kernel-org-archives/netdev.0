From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] bonding: cancel_delayed_work() ->
	cancel_delayed_work_sync()
Date: Thu, 17 Dec 2009 13:36:44 +0000
Message-ID: <20091217133644.GD8654@ff.dom.local>
References: <20091217002808.E44D0254177@hockey.mtv.corp.google.com> <20091217074930.GA6779@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mikhail Markine <markine@google.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Petri Gynther <pgynther@google.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:41981 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935629AbZLQNgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 08:36:47 -0500
Received: by fxm21 with SMTP id 21so1885760fxm.21
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 05:36:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091217074930.GA6779@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, Dec 17, 2009 at 02:19:46PM +0100, Johannes Berg wrote:
> Jarek,
> 
> Sorry to mail you directly, but I only saw your reply on gmane and
> didn't want to break up the threading etc.
> 
> cancel_delayed_work_sync() should be ok in this case unless the work
> items themselves used the rtnl,

Hmm, I'm not sure I get your point, but e.g. bond_mii_monitor() work
function can get rtnl_lock().

> the common problem only happens with
> flush_scheduled_work() -- sync() is fine since either it's running, then
> you need the sync, or if it's not running it doesn't matter if something
> else is on the queue before it that's blocked on the rtnl.
> 
> If you could reply to the thread to that effect I'd appreciate it :)

No problem with this question :-)
Jarek P.
