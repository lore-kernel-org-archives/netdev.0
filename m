From: Florian Westphal <fw@strlen.de>
Subject: Re: Increasing skb->mark size
Date: Mon, 30 Nov 2015 03:08:16 +0100
Message-ID: <20151130020816.GB29878@breakpoint.cc>
References: <1448397144.14854.27.camel@mattb-dl>
 <20151124203602.GB23215@breakpoint.cc>
 <1448398614.14854.39.camel@mattb-dl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "fw@strlen.de" <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>,
	Kyeong Yoo <Kyeong.Yoo@alliedtelesis.co.nz>
To: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42364 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751853AbbK3CIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 21:08:19 -0500
Content-Disposition: inline
In-Reply-To: <1448398614.14854.39.camel@mattb-dl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Bennett <Matt.Bennett@alliedtelesis.co.nz> wrote:
> On Tue, 2015-11-24 at 21:36 +0100, Florian Westphal wrote:
> > Matt Bennett <Matt.Bennett@alliedtelesis.co.nz> wrote:
> > > I'm emailing this list for feedback on the feasibility of increasing
> > > skb->mark or adding a new field for marking. Perhaps this extension
> > > could be done under a new CONFIG option. Perhaps there are other ways we
> > > could achieve the desired behaviour?
> > 
> > Well I pointed you towards connlabels which provide 128 bit of space
> > in the conntrack extension area but you did not tell me why you cannot
> > use it.
> Sorry, I moved the discussion to this list to hopefully gather some new
> ideas/opinions.
> 
> While connlabels provide 128bits of space skb->mark is still only 32
> bits. Since we are using connection tracking to simply restore skb->mark
> the use of connlabels by itself doesn't solve the problem I outlined
> above. skb->mark would still needs to be increased in size.

We have ctnetlink which allows direct setting of ctmark/ctlabels.

Regarding ctlabels, they were originally designed to provide a bit-set
so that ctmark could be used as an 'enumeration' type while ctlabels
could be used to provide distinct, non-overlapping labels.
