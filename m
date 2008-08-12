From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11297] New: OOPS in rt6_fill_node
Date: Mon, 11 Aug 2008 18:40:26 -0700 (PDT)
Message-ID: <20080811.184026.02436525.davem@davemloft.net>
References: <48A0DC27.7030208@hp.com>
	<28fa9c5e0808111810l63220abbgf9e747bad3a7fe44@mail.gmail.com>
	<28fa9c5e0808111828w2a9f1133y75c785f70b683ff2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, parag.warudkar@gmail.com,
	akpm@linux-foundation.org, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
To: eugeneteo@kernel.sg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58288
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751207AbYHLBkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 21:40:25 -0400
In-Reply-To: <28fa9c5e0808111828w2a9f1133y75c785f70b683ff2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eugene Teo" <eugeneteo@kernel.sg>
Date: Tue, 12 Aug 2008 09:28:05 +0800

> On Tue, Aug 12, 2008 at 9:10 AM, Eugene Teo <eugeneteo@kernel.sg> wrote:
> > On Tue, Aug 12, 2008 at 8:41 AM, Brian Haley <brian.haley@hp.com> wrote:
> >> Parag Warudkar wrote:
> >>>
> >>> What output do you see with your patch?
> >>
> >> # ip -f inet6 route get fec0::1
> >> unreachable fec0::1 dev lo  table unspec  proto none  src
> >> 2001:1890:1109:a10:218:feff:fe7f:49c8  metric -1  error -101 hoplimit 255
> >
> > Hmm, I tried it on an older kernel that doesn't have Yoshfuji-san's
> > ipv6_get_saddr() changes,
> > and it should display the output with the loopback MAC address instead
> > of ethX MAC address.
> > Correct me if I am wrong.
> 
> Evidence of me still sleepy. Not the MAC address but the ipv6 address...

Hmmm... from what I understand so far based upon Parag's most
recent reply, Brian's patch should be OK.

Does everyone else agree?

