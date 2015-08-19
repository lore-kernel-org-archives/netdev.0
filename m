From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 20/21] net: warn if drivers set tx_queue_len = 0
Date: Wed, 19 Aug 2015 22:21:04 +0200
Message-ID: <20150819202104.GB12537@orbit.nwl.cc>
References: <1439886649-24166-14-git-send-email-phil@nwl.cc>
 <1439886649-24166-15-git-send-email-phil@nwl.cc>
 <1439886649-24166-16-git-send-email-phil@nwl.cc>
 <1439886649-24166-17-git-send-email-phil@nwl.cc>
 <1439886649-24166-18-git-send-email-phil@nwl.cc>
 <1439886649-24166-19-git-send-email-phil@nwl.cc>
 <1439886649-24166-20-git-send-email-phil@nwl.cc>
 <1439886649-24166-21-git-send-email-phil@nwl.cc>
 <1439909248.6443.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150819183924.GA12537@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:34949 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525AbbHSUVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 16:21:06 -0400
Content-Disposition: inline
In-Reply-To: <20150819183924.GA12537@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 08:39:24PM +0200, Phil Sutter wrote:
[...]
> I'll start implementing the above immediately, but would appreciate to
> hear your comments on it meanwhile. I wonder especially what makes the
> difference between pfifo and pfifo_fast and why the latter can't be
> selected explicitly by a user yet. Are there any good reasons for it
> aside from it being the "default" and therefore selecting it can be done
> by having tx_queue_len > 0 and removing the root qdisc?

Please ignore most of my questions regarding pfifo_fast here. I based my
assumptions upon 'tc' utility of RHEL7, which is buggy in that it does
not allow to add qdiscs which do not support extra options. Using
mainline tc, pfifo_fast can be attached just like any other qdisc.

Sorry for the noise,

Phil
