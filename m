From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Strange TCP behavior over HSDPA
Date: Tue, 29 Dec 2009 13:36:20 +0000
Message-ID: <20091229133620.GA9552@ff.dom.local>
References: <20091229083050.GA7209@ff.dom.local> <4B39D30F.8090006@gmail.com> <20091229105748.GB7209@ff.dom.local> <20091229121624.GC7209@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:34868 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbZL2Ng3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 08:36:29 -0500
Received: by fg-out-1718.google.com with SMTP id 22so4522601fge.1
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 05:36:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091229121624.GC7209@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2009 at 12:16:24PM +0000, Jarek Poplawski wrote:
> On Tue, Dec 29, 2009 at 10:57:48AM +0000, Jarek Poplawski wrote:
> > Did you try to turn off TCP window scaling btw? Anyway, under the
> > tunnel ([2]), when SACK worked, it saved you a lot of retransmits.
> 
> Hmm... Actually, after re-checking, there weren't much more of those
> retransmits at all. In [1] there was one more packet lost, so it took
> a bit longer. In [2] (with SACK) the retransmit started earlier and
> the rcv window was unchanged. So, it rather looks like differences
> in timing of TCP recovery techniques.

Hmm#2... On the other hand, I can imagine cases with a larger data
loss, where working SACK should really save on retransmits.

Jarek P.
