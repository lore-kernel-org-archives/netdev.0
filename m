From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] tipc: cleanup function namespace
Date: Wed, 13 Oct 2010 21:29:52 -0400
Message-ID: <20101014012951.GA2186@localhost.localdomain>
References: <1286929558-2954-5-git-send-email-paul.gortmaker@windriver.com>
 <20101013162652.GF31379@hmsreliant.think-freely.org>
 <4CB5E79B.4060507@windriver.com>
 <20101013.142834.226768662.davem@davemloft.net>
 <20101013162035.0c2e8123@nehalam>
 <4CB64D7C.1080004@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36929 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688Ab0JNBaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 21:30:02 -0400
Content-Disposition: inline
In-Reply-To: <4CB64D7C.1080004@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 13, 2010 at 08:23:24PM -0400, Paul Gortmaker wrote:
> On 10-10-13 07:20 PM, Stephen Hemminger wrote:
> > Do some cleanups of TIPC based on make namespacecheck
> >    1. Don't export unused symbols
> >    2. Eliminate dead code
> >    3. Make functions and variables local
> >    4. Rename buf_acquire to tipc_buf_acquire since it is used in several files
> > 
> > Compile tested only.
> > This make break out of tree kernel modules that depend on TIPC routines.
> 
> Hi Stephen,
> 
> When I first started looking at TIPC code, I too came to the
> same conclusion as you did and was about to do #1,2,3 -- but
> then I was told that the exported symbols were part of an API
> and might be in use by folks here and there as per this thread:
> 
> http://www.mail-archive.com/netdev@vger.kernel.org/msg30208.html
> 
I think its telling the the argument in the above thread for keeping the API
were that users of it were out there and 'likely to contribute' in the future.
That thread was 3 years ago.  They might be using the API from outside the
kernel tree, but they're not planning on contributing.  As Christoph noted,
they're freeloaders.  The community really doesn't need or want to maintain an
API like that.  If these users are your customers, and removing the API is
unacceptable, perhaps its time to move the entire TIPC module out of tree.

Neil

