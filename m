From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: switching network namespace midway
Date: Thu, 25 Oct 2012 11:59:28 -0400
Message-ID: <20121025155927.GI15034@kvack.org>
References: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com> <878vavshhp.fsf@xmission.com> <20121024212116.GG15034@kvack.org> <CAFaHj6Ey4vzXskvsKB_dG4fKGsn4X5oCF3N0YpGskiSaXrGSOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: rsa <ravi.mlists@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:50121 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932678Ab2JYP73 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 11:59:29 -0400
Content-Disposition: inline
In-Reply-To: <CAFaHj6Ey4vzXskvsKB_dG4fKGsn4X5oCF3N0YpGskiSaXrGSOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 25, 2012 at 11:29:34AM -0400, rsa wrote:
> Hi Ben
> For L2TP that should work very well. But, with other tunnel types like GRE etc.
> route lookups have to be done first in the inner and then outer.  It
> makes it easier
> to keep keep the tunnel in the inner namespace in such cases. right?

I've read IPv4 gre code, and it appears to do the right thing on rx, but it 
does *not* appear to handle namespaces correctly on transmit.  In general, 
I would expect pretty much all code to get namespace handling correct for 
the rx case.  I'll have a closer look at fixing this tomorrow if nobody else 
beats me to it.

		-ben
-- 
"Thought is the essence of where you are now."
