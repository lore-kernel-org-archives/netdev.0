From: Andi Kleen <ak@suse.de>
Subject: Re: Zero copy transmit
Date: Tue, 29 Apr 2003 21:59:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429195924.GC349@Wotan.suse.de>
References: <3EAEC7FF.4040504@sgi.com> <20030429192041.GC17413@Wotan.suse.de> <3EAED567.2090006@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
Content-Disposition: inline
In-Reply-To: <3EAED567.2090006@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> At issue is really application capture and customer adoption.  There are
> tons of apps and lots of engineers that know socket operations and 
> write/writev.  Asking all ISVs to recode for linux would leave them with 
> two separate APIs to deal with. They would have send/sendto or 
> write/writev on Solaris, HPUX and whatever else, and linux would have 
> sendfile.

aio_write / lio_listio exists on Solaris and HP/UX too.

(and even Windows; their completion port interfaces are very similar) 

> 
> We really want to do this in such a way that it doesn't create a huge 
> footprint (and we think we can) and we want to make sure we don't impact 
> systems that can't take advantage of fast TLB updates.

So how do you avoid the two TLB flush IPIs to all CPUs that have the current mm
mapped ?

-Andi
