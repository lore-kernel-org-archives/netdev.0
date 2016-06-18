From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 1/3] Use C99 style initializers everywhere
Date: Fri, 17 Jun 2016 17:21:26 -0700
Message-ID: <20160617172126.1d26262e@xeon-e3>
References: <576420B0.3050203@iogearbox.net>
	<20160618000221.GA10428@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	<netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"julien.floret@6wind.com" <julien.floret@6wind.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:23190 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752316AbcFRAVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 20:21:37 -0400
In-Reply-To: <20160618000221.GA10428@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 18 Jun 2016 02:02:21 +0200
Phil Sutter <phil@nwl.cc> wrote:

> On Fri, Jun 17, 2016 at 11:57:53AM -0700, Stephen Hemminger wrote:
> > It makes sense that if you can build a kernel with old toolchain, that
> > iproute2 needs to be buildable as well.
> > 
> > The current kernels are documented to require 3.2 or later.  
> 
> So in your opinion we should stay compatible to gcc-3.2? Clarifying
> requirements like this one would make sense in order to know what to
> check against.


I want to have the least user complaints possible.
Since the main reason people build new iproute2 utilities is to work with features
of newer kernels. It makes sense to keep the requirements the same. Not sure if kernel
still builds with gcc-3.2, has anyone tried.
