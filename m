From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net 2/3] gre: build header correctly for collect metadata
 tunnels
Date: Sat, 23 Apr 2016 10:03:30 +1000
Message-ID: <20160423000326.GA13690@penelope.isobedori.kobe.vergenet.net>
References: <cover.1461346798.git.jbenc@redhat.com>
 <7778b1a1e2123d3c9bf541d671fe62caeb6e9fd5.1461346798.git.jbenc@redhat.com>
 <CAOrHB_CbD7ycnSJ4ewkj1WOu-qnYmwAYtusj1M4cfAhtN5J20Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@redhat.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:32901 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbcDWADs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 20:03:48 -0400
Received: by mail-pf0-f173.google.com with SMTP id 184so46104002pff.0
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 17:03:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOrHB_CbD7ycnSJ4ewkj1WOu-qnYmwAYtusj1M4cfAhtN5J20Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2016 at 02:05:06PM -0700, pravin shelar wrote:
> On Fri, Apr 22, 2016 at 10:44 AM, Jiri Benc <jbenc@redhat.com> wrote:
> > In ipgre (i.e. not gretap) + collect metadata mode, the skb was assumed to
> > contain Ethernet header and was encapsulated as ETH_P_TEB. This is not the
> > case, the interface is ARPHRD_IPGRE and the protocol to be used for
> > encapsulation is skb->protocol.
> >
> > Fixes: 2e15ea390e6f4 ("ip_gre: Add support to collect tunnel metadata.")
> > Signed-off-by: Jiri Benc <jbenc@redhat.com>
> 
> Acked-by: Pravin B Shelar <pshelar@ovn.org>

Reviewed-by: Simon Horman <simon.horman@netronome.com>
