From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 v2 0/4] Switch network ns w/o 'netns exec' for
 iproute2 tools
Date: Sat, 27 Dec 2014 22:24:10 +0200
Message-ID: <20141227202410.GA1283@angus-think.lan>
References: <1419455051-23397-1-git-send-email-vadim4j@gmail.com>
 <20141227102453.4f4093f5@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:51124 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbaL0UeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2014 15:34:20 -0500
Received: by mail-wi0-f171.google.com with SMTP id bs8so19163765wib.10
        for <netdev@vger.kernel.org>; Sat, 27 Dec 2014 12:34:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141227102453.4f4093f5@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 27, 2014 at 10:24:53AM -0800, Stephen Hemminger wrote:
> On Wed, 24 Dec 2014 23:04:07 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > This series adds new -n[etns] option to ip, tc & bridge tools which
> > allows to easy and faster switch to specified network namespace. So instead of:
> > 
> >     ip netns exec NETNS { ip | tc | bridge } OBJECT COMMAND
> > 
> > it will be possible do the same by:
> > 
> >     { ip | tc | bridge } -n[etns] NETNS OBJECT COMMAND
> > 
> > I skipped misc tools and will work on them later.
> > 
> > Vadim Kochan (4):
> >   lib: Add netns_switch func for change network namespace
> >   ip: Allow to easy change network namespace
> >   bridge: Allow to easy change network namespace
> >   tc: Allow to easy change network namespace
> > 
> >  bridge/Makefile     |   4 ++
> >  bridge/bridge.c     |   7 +++-
> >  include/namespace.h |  46 +++++++++++++++++++++++
> >  ip/ip.c             |   7 +++-
> >  ip/ipnetns.c        | 106 ++--------------------------------------------------
> >  lib/Makefile        |   6 ++-
> >  lib/namespace.c     |  86 ++++++++++++++++++++++++++++++++++++++++++
> >  man/man8/bridge.8   |  23 +++++++++++-
> >  man/man8/ip.8       |  23 +++++++++++-
> >  man/man8/tc.8       |  65 ++++++++++++++++++++++++--------
> >  tc/Makefile         |   5 +++
> >  tc/tc.c             |   8 +++-
> >  12 files changed, 262 insertions(+), 124 deletions(-)
> >  create mode 100644 include/namespace.h
> >  create mode 100644 lib/namespace.c
> 
> Applied.
> Note: kernel.org git is not available so will push later.
> 
Seems works now.
