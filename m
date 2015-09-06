From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH] net: kill default_pref field of struct
 fib_rules_ops
Date: Sun, 6 Sep 2015 11:54:30 +0200
Message-ID: <20150906095349.0AC0E20900@mail.nwl.cc>
References: <1441198992-25359-1-git-send-email-phil@nwl.cc>
 <1441278622-24679-1-git-send-email-phil@nwl.cc>
 <20150905.220040.768580139044156666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:34178 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386AbbIFJxv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Sep 2015 05:53:51 -0400
Content-Disposition: inline
In-Reply-To: <20150905.220040.768580139044156666.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 05, 2015 at 10:00:40PM -0700, David Miller wrote:
> From: Phil Sutter <phil@nwl.cc>
> Date: Thu,  3 Sep 2015 13:10:22 +0200
> 
> > Since now all users of that field have been converted to use the generic
> > function fib_default_rule_pref() when assigning to it, fib_nl_newrule()
> > may just use it directly instead.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> 
> I did not instruct you to submit this change assuming I had applied
> your ipv6 one.  Which I did not and will not do.
> 
> Instead, I want you to do it all in one go.

Ah. No biggie, I'll fold them together then. Just found it useful to
separate the logically unrelated changes in different commits.

Cheers, Phil
