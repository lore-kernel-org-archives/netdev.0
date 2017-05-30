From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH RFC net-next] arp: Really delete an arp entry on "arp -d"
Date: Tue, 30 May 2017 19:32:32 -0400
Message-ID: <20170530233232.GL23089@oracle.com>
References: <1496116096-77316-1-git-send-email-sowmini.varadhan@oracle.com>
 <20170530162020.137aef02@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29900 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbdE3Xcl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 19:32:41 -0400
Content-Disposition: inline
In-Reply-To: <20170530162020.137aef02@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (05/30/17 16:20), Stephen Hemminger wrote:
> 
> Please don't copy/paste chunks of code. Instead refactor and make this
> into a helper function. 

sure, I have no problems with that, and as I pointed out, I've not
tested ipv6 for this yet either. I'll do all of this after getting
some feedback on the more basic issue here:

I was first looking for comments on the more fundamental refcnt
management behind the fix (I'm surprised no one noticed this 
before, is there some deep reason for leaving it like this, that
I am missing? Does it break something else?)

And fwiw I was merging pieces of ___neigh_lookup_noref, which figures
out the hash val, and neigh_flush_dev/neigh_forced_gc 
