From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] lib utils: fix family during af_bit_len
 calculation
Date: Thu, 26 Mar 2015 18:28:34 +0200
Message-ID: <20150326162834.GA32500@angus-think.wlc.globallogic.com>
References: <1426645109-3411-1-git-send-email-roopa@cumulusnetworks.com>
 <20150324150500.6159e407@urahara>
 <1427290352.25985.111.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150325161349.GA21340@angus-think.wlc.globallogic.com>
 <1427303247.25985.119.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150326140418.GA12220@angus-think.wlc.globallogic.com>
 <1427387645.25985.138.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	roopa@cumulusnetworks.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:36553 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbbCZQkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 12:40:31 -0400
Received: by lbbug6 with SMTP id ug6so45240922lbb.3
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 09:40:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427387645.25985.138.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 09:34:05AM -0700, Eric Dumazet wrote:
> On Thu, 2015-03-26 at 16:04 +0200, Vadim Kochan wrote:
> > On Wed, Mar 25, 2015 at 10:07:27AM -0700, Eric Dumazet wrote:
> > > On Wed, 2015-03-25 at 18:13 +0200, Vadim Kochan wrote:
> > > 
> > > > I reproduced this once, but after not any more, I even tried to setup
> > > > tcp servers with same address but with no luck, would you please dump
> > > > stats into file by -D option and send it, in case if you will catch the
> > > > issue ?
> > > 
> > > Yeah, this is strange, because after a small change, and a revert, I
> > > could not reproduce it anymore.
> > > 
> > > Something fishy... maybe a Makefile bug ....
> > > 
> > > 
> > 
> > Seems this issue is already fixed by this patch from Roopa, because when I
> > switched to the commit before the fix then I reproduced the issue. I
> > meant the issue related to :
> > 
> >     ss -t dst 1.2.3.4
> 
> Yes, but I had my git tree up to date, and misc/ss rebuilt.
> 
> Let's say it was some kind of user error.
> 
> 

I assume that may be if you did rebuild only misc/ss then probably it
used the old lib/utils.o which still had buggy func for parsing address ?
