From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] tipc: cleanup function namespace
Date: Thu, 14 Oct 2010 11:33:20 -0700
Message-ID: <20101014113320.7720828f@nehalam>
References: <1286929558-2954-5-git-send-email-paul.gortmaker@windriver.com>
	<20101013162652.GF31379@hmsreliant.think-freely.org>
	<4CB5E79B.4060507@windriver.com>
	<20101013.142834.226768662.davem@davemloft.net>
	<20101013162035.0c2e8123@nehalam>
	<4CB64D7C.1080004@windriver.com>
	<20101014012951.GA2186@localhost.localdomain>
	<4CB74391.9020400@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	allan.stephens@windriver.com, Jon Maloy <jon.maloy@ericsson.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48302 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754807Ab0JNSdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 14:33:25 -0400
In-Reply-To: <4CB74391.9020400@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Oct 2010 13:53:21 -0400
Paul Gortmaker <paul.gortmaker@windriver.com> wrote:

> On 10-10-13 09:29 PM, Neil Horman wrote:
> > On Wed, Oct 13, 2010 at 08:23:24PM -0400, Paul Gortmaker wrote:
> >> On 10-10-13 07:20 PM, Stephen Hemminger wrote:
> >>> Do some cleanups of TIPC based on make namespacecheck
> >>>     1. Don't export unused symbols
> >>>     2. Eliminate dead code
> >>>     3. Make functions and variables local
> >>>     4. Rename buf_acquire to tipc_buf_acquire since it is used in several files
> >>>
> >>> Compile tested only.
> >>> This make break out of tree kernel modules that depend on TIPC routines.
> >>
> >> Hi Stephen,
> >>
> >> When I first started looking at TIPC code, I too came to the
> >> same conclusion as you did and was about to do #1,2,3 -- but
> >> then I was told that the exported symbols were part of an API
> >> and might be in use by folks here and there as per this thread:
> >>
> >> http://www.mail-archive.com/netdev@vger.kernel.org/msg30208.html
> >>
> > I think its telling the the argument in the above thread for keeping the API
> > were that users of it were out there and 'likely to contribute' in the future.
> > That thread was 3 years ago.  They might be using the API from outside the
> > kernel tree, but they're not planning on contributing.  As Christoph noted,
> > they're freeloaders.  The community really doesn't need or want to maintain an
> > API like that.  If these users are your customers, and removing the API is
> > unacceptable, perhaps its time to move the entire TIPC module out of tree.
> 
> As I'd said -- I don't know what the use cases of these API users are,
> and so as far as I know they aren't customers either.  For what it is
> worth, know that I personally wouldn't try and use a business case to
> justify a technically wrong decision here on netdev anyway.
> 
> I was just describing the history of the situation, and suggesting
> one possible slower approach of phasing it out as a courtesy to those
> users, in the same way that the kernel community has extended that
> same courtesy with other things in feature-removal.txt
> 
> In the end, since Jon is OK with the removal, and is in the process of
> communicating this to the API users he is aware of, I sure don't have
> any reason to try and save the API.  If folks are good with having it
> just go away overnight, then great -- I'll be just as happy to see it
> disappear as you and Stephen.  So, a long winded way of saying...
> 
> Acked-by: Paul Gortmaker <paul.gortmaker@windriver.com>

How about putting an entry in feature-removal.txt with a short (6 month)
window?


-- 
