From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH v2] ROSE: prevent heap corruption with bad facilities
Date: Fri, 1 Apr 2011 14:29:38 +0200
Message-ID: <20110401122938.GA2908@midget.suse.cz>
References: <1300603423.1869.18.camel@dan>
 <1300639685.26693.286.camel@localhost>
 <20110331180225.GA6677@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Dan Rosenberg <drosenberg@vsecurity.com>, ralf@linux-mips.org,
	davem@davemloft.net, netdev@vger.kernel.org, security@kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47754 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753159Ab1DAM3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2011 08:29:42 -0400
Content-Disposition: inline
In-Reply-To: <20110331180225.GA6677@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2011 at 08:02:25PM +0200, Jiri Bohac wrote:
> However, I wonder how much sense it makes to continue parsing the
> facilities if an unknown facility family appears. We don't know
> the length of its data, so we will interpret each 16 bytes a new

oops, typo:
s/16 bytes a new/16 bits as a new/

> facilities header, hopefully soon bailing out on *p != 0x00.
> 
> In case of a long packet where every other byte is zero, the loop
> will spam the kernel log with the printk ... which could probably
> be classified as a security problem on its own. So how about the
> following instead? I have no idea if this breaks some rose
> specification, though. 
-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

