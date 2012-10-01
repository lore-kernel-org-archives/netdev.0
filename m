From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Mon, 01 Oct 2012 22:04:44 +0200
Message-ID: <1349121884.12401.721.camel@edumazet-glaptop>
References: <506955F3.8050304@googlemail.com>
	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <20121001193434.GA14236@redhat.com>
	 <20121001.160115.1816241312626722150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, chris2553@googlemail.com, netdev@vger.kernel.org,
	gpiez@web.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47983 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776Ab2JAUEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 16:04:49 -0400
Received: by bkcjk13 with SMTP id jk13so5178095bkc.19
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2012 13:04:48 -0700 (PDT)
In-Reply-To: <20121001.160115.1816241312626722150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-01 at 16:01 -0400, David Miller wrote:
> From: Dave Jones <davej@redhat.com>
> Date: Mon, 1 Oct 2012 15:34:34 -0400
> 
> > On Mon, Oct 01, 2012 at 11:15:50AM +0200, Eric Dumazet wrote:
> >  > > 
> >  > > $ netstat -s
> >  > > Icmp:
> >  > >      4 ICMP messages received
> >  > >      4 input ICMP message failed.
> >  > >      ICMP input histogram:
> >  > >          echo replies: 4
> >  > 
> >  > So icmp replies come back and are delivered to host instead of being
> >  > forwarded.
> >  > 
> >  > I wonder if MASQUERADE broke...
> > 
> > I hit something that sounds just like this a few months back..
> > http://lists.openwall.net/netdev/2012/07/25/53
> > 
> > It "went away" a few builds later, but I've seen it happen
> > again from time to time.
> 
> Yep I remembe that report.
> 
> If you can find a way to more reliably trigger the case, that would
> help us immensely.

I am building a KMEMCHECK kernel, as a last try before my night ;)
