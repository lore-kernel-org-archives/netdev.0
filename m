From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net: fix checking boundary of valid vlan id
Date: Sun, 30 Dec 2012 13:25:42 +0100
Message-ID: <20121230122542.GC11727@breakpoint.cc>
References: <1356848931-22193-1-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: akong@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49382 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754482Ab2L3MZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 07:25:49 -0500
Content-Disposition: inline
In-Reply-To: <1356848931-22193-1-git-send-email-akong@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akong@redhat.com <akong@redhat.com> wrote:
> From: Amos Kong <akong@redhat.com>
> 
> 4096 is not a valid vlan id.

True.

But why shouldn't users be allowed to check for frames
with reserved value?
