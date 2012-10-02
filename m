From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Tue, 02 Oct 2012 17:35:33 +0200
Message-ID: <1349192133.12401.768.camel@edumazet-glaptop>
References: <506955F3.8050304@googlemail.com>
	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <20121001193434.GA14236@redhat.com>
	 <20121001.160115.1816241312626722150.davem@davemloft.net>
	 <1349121884.12401.721.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, chris2553@googlemail.com, netdev@vger.kernel.org,
	gpiez@web.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60197 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545Ab2JBPfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 11:35:39 -0400
Received: by bkcjk13 with SMTP id jk13so5589113bkc.19
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2012 08:35:37 -0700 (PDT)
In-Reply-To: <1349121884.12401.721.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-01 at 22:04 +0200, Eric Dumazet wrote:
> On Mon, 2012-10-01 at 16:01 -0400, David Miller wrote:

> > If you can find a way to more reliably trigger the case, that would
> > help us immensely.
> 
> I am building a KMEMCHECK kernel, as a last try before my night ;)

This was a total disaster. KMEMCHECK dies horribly on my machine

David, shouldnt we use a nh_rth_forward instead of a nh_rth_input in
__mkroute_input() ?

(And change rt_cache_route() as well ?)

I am testing a patch right now.
