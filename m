From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC 3/3] tc: cleanup tc_classify
Date: Thu, 23 Apr 2015 09:49:27 +0100
Message-ID: <20150423084927.GI21799@casper.infradead.org>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
 <1429644476-8914-4-git-send-email-ast@plumgrid.com>
 <CAHA+R7OSVs1rYcXkOM=FYoDMHGM30iWRRAVtdiJmU7jz9GRdYw@mail.gmail.com>
 <55382055.1090207@plumgrid.com>
 <CAHA+R7Mzz-6j1u=6KqVgT1pesbWcon+=EZcsVU6VX7wm1zEUVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34527 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756713AbbDWIt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 04:49:28 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7Mzz-6j1u=6KqVgT1pesbWcon+=EZcsVU6VX7wm1zEUVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/15 at 04:38pm, Cong Wang wrote:
> On Wed, Apr 22, 2015 at 3:27 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> > On 4/21/15 10:05 PM, Cong Wang wrote:
> >>
> >> On Tue, Apr 21, 2015 at 12:27 PM, Alexei Starovoitov <ast@plumgrid.com>
> >> wrote:
> >>>
> >>> introduce tc_classify_act() and qdisc_drop_bypass() helper functions to
> >>> reduce
> >>> copy-paste among different qdiscs

I like this cleanup. It aligns all skb dropping in qdiscs to a
qdisc_drop*() function.

> >> I don't think qdisc_drop_bypass() is more readable than without it,
> >> maybe you need a better name, or just leave the code as it is.
> >
> >
> > what would be a better name? I'm open to suggestions.
> 
> My reading for "qdisc_drop_bypass()" is it bypasses packet
> dropping for some case, apparently doesn't match its definition.
> 
> I can't think out a better name therefore I don't think it deserves
> a function, just leave as it is.

Interesting logic ;-)
