From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 0/8]: uninline & uninline
Date: Sat, 23 Feb 2008 14:15:06 +0100
Message-ID: <p734pbz95lx.fsf@bingen.suse.de>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20080223000220.e9229c99.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:44820 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751376AbYBWNPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Feb 2008 08:15:08 -0500
In-Reply-To: <20080223000220.e9229c99.akpm@linux-foundation.org> (Andrew Morton's message of "Sat\, 23 Feb 2008 00\:02\:20 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> writes:


>> -41525  2066 f, 3370 +, 44895 -, diff: -41525  IS_ERR 
>
> This is a surprise.  I expect that the -mm-only
> profile-likely-unlikely-macros.patch is the cause of this and mainline
> doesn't have this problem.

Shouldn't they only have overhead when the respective CONFIG is enabled?

> If true, then this likely/unlikely bloat has probably spread into a lot of
> your other results and it all should be redone against mainline, sorry :(
>
> (I'm not aware of anyone having used profile-likely-unlikely-macros.patch
> in quite some time.  That's unfortunate because it has turned up some
> fairly flagrant code deoptimisations)

Is there any reason they couldn't just be merged to mainline? 

I think it's a useful facility.

-Andi
