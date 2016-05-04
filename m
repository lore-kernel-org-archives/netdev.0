From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH next-next 2/7] gre: Move utility functions to common
 headers
Date: Wed, 4 May 2016 10:35:49 +0200
Message-ID: <20160504103549.228c9e8a@griffin>
References: <1461975141-954269-1-git-send-email-tom@herbertland.com>
	<1461975141-954269-3-git-send-email-tom@herbertland.com>
	<20160503132944.1951cefb@griffin>
	<20160504.005316.762406965746230352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58770 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757788AbcEDIfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 04:35:53 -0400
In-Reply-To: <20160504.005316.762406965746230352.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 04 May 2016 00:53:16 -0400 (EDT), David Miller wrote:
> From: Jiri Benc <jbenc@redhat.com>
> Date: Tue, 3 May 2016 13:29:44 +0200
> 
> > How do we resolve the conflict between net and net-next? I'd prefer
> > gre_parse_header to return the header length. I can submit a patch for
> > net-next that does this; that would substantially ease the merge.
> 
> Jiri, I just did the net --> net-next merge.  Please send me something on
> top of that which does what you like.

The patch http://patchwork.ozlabs.org/patch/617940/ still applies and
does the right thing even post merge.

Note that the merge reintroduced the bug fixed by b7f8fe251e46 (the
mentioned patch fixes this, too).

Thanks,

 Jiri
