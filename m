From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Zero copy transmit
Date: Tue, 29 Apr 2003 21:17:37 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429211737.A9926@infradead.org>
References: <3EAEC7FF.4040504@sgi.com> <20030429192041.GC17413@Wotan.suse.de> <3EAED567.2090006@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
Content-Disposition: inline
In-Reply-To: <3EAED567.2090006@sgi.com>; from modica@sgi.com on Tue, Apr 29, 2003 at 02:41:27PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 29, 2003 at 02:41:27PM -0500, Steve Modica wrote:
> At issue is really application capture and customer adoption.  There are
> tons of apps and lots of engineers that know socket operations and 
> write/writev.  Asking all ISVs to recode for linux would leave them with 
> two separate APIs to deal with. They would have send/sendto or 
> write/writev on Solaris, HPUX and whatever else, and linux would have 
> sendfile.

Solaris and HPUX have sendfile, the HPUX one has a slightly different
API, the Solaris one is modelled after Linux.
