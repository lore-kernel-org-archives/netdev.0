From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/2] net: introduce IFF_NO_QUEUE as successor of zero
 tx_queue_len
Date: Thu, 13 Aug 2015 10:49:50 -0700
Message-ID: <20150813104950.1b8346f2@urahara>
References: <1439485268-20953-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com,
	alexei.starovoitov@gmail.com, davem@davemloft.net, fw@strlen.de,
	cwang@twopensource.com, eric.dumazet@gmail.com
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36850 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210AbbHMRtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 13:49:42 -0400
Received: by pacrr5 with SMTP id rr5so41873747pac.3
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 10:49:40 -0700 (PDT)
In-Reply-To: <1439485268-20953-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Aug 2015 19:01:05 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Up to now, drivers being aware of the above applying to them set
> dev->tx_queue_len to zero to indicate no qdisc should be attached to the
> interface they drive and the kernel reacts upon this by assigning the noop
> qdisc instead of the default pfifo_fast. This implicit agreement though leads
> to an inconvenient situation once a user tries to attach a real qdisc to these
> devices, as the formerly special tx_queue_len value becomes a regular one,

So this is a workaround for user ignorance by introducing kernel API complexity.
Before user sets qdisc, why don't they set tx queue length?
