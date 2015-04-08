From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs
 consistent
Date: Wed, 8 Apr 2015 14:47:38 +0100
Message-ID: <20150408134738.GB28656@casper.infradead.org>
References: <20150408090520.GA2057@nanopsycho.orion>
 <552508E8.5050203@iogearbox.net>
 <55250D92.6030702@iogearbox.net>
 <55251556.4040900@mojatatu.com>
 <55251F9F.2050508@iogearbox.net>
 <55252611.3040109@mojatatu.com>
 <20150408131417.GA28656@casper.infradead.org>
 <55252CDD.8020503@iogearbox.net>
 <20150408133415.GD2057@nanopsycho.orion>
 <55252FEF.40201@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47306 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754300AbbDHNrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 09:47:40 -0400
Content-Disposition: inline
In-Reply-To: <55252FEF.40201@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/15 at 03:41pm, Daniel Borkmann wrote:
> On 04/08/2015 03:34 PM, Jiri Pirko wrote:
> >That is certainly doable. But is that what we want? I don't think so. I
> >would like to have the same for in/eg.
> 
> I mean it's certainly a non-obvious hack, where user space has to
> fix up something that the kernel should have gotten right in the
> first place. :/

We should be careful to not break existing scripts. I realize
it's horribly broken but this stuff is being used.

We need the user to signal that he is aware that offsets changed
and subtract the ll header from offsets of unaware users.
