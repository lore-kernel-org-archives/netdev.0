From: Dave Jones <davej@redhat.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Tue, 2 Oct 2012 11:57:38 -0400
Message-ID: <20121002155738.GA20331@redhat.com>
References: <506955F3.8050304@googlemail.com>
 <1349082950.12401.669.camel@edumazet-glaptop>
 <20121001193434.GA14236@redhat.com>
 <20121001.160115.1816241312626722150.davem@davemloft.net>
 <1349121884.12401.721.camel@edumazet-glaptop>
 <1349192133.12401.768.camel@edumazet-glaptop>
 <1349192919.12401.778.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, chris2553@googlemail.com,
	netdev@vger.kernel.org, gpiez@web.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19753 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754712Ab2JBP5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 11:57:45 -0400
Content-Disposition: inline
In-Reply-To: <1349192919.12401.778.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 02, 2012 at 05:48:39PM +0200, Eric Dumazet wrote:
 > From: Eric Dumazet <edumazet@google.com>
 > 
 > On Tue, 2012-10-02 at 17:35 +0200, Eric Dumazet wrote:
 > > On Mon, 2012-10-01 at 22:04 +0200, Eric Dumazet wrote:
 > > > On Mon, 2012-10-01 at 16:01 -0400, David Miller wrote:
 > > 
 > > > > If you can find a way to more reliably trigger the case, that would
 > > > > help us immensely.
 > > > 
 > > > I am building a KMEMCHECK kernel, as a last try before my night ;)
 > > 
 > > This was a total disaster. KMEMCHECK dies horribly on my machine
 > > 
 > > David, shouldnt we use a nh_rth_forward instead of a nh_rth_input in
 > > __mkroute_input() ?
 > > 
 > > (And change rt_cache_route() as well ?)
 > > 
 > > I am testing a patch right now.
 > 
 > Yeah, this patch seems to fix the bug for me.

Good work! Any idea why it didn't happen on every build for me ?

>From your description, this should have failed every time ?

	Dave
