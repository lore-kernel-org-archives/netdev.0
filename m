From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2] ip{,6}tunnel: have a shared stats
 parser/printer
Date: Mon, 21 Dec 2015 20:36:58 +0100
Message-ID: <20151221193533.9F13761201@mail.nwl.cc>
References: <20151218105225.GA19288@orbyte.nwl.cc>
 <1450436286-14882-1-git-send-email-phil@nwl.cc>
 <5677DBB6.3070008@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58502 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291AbbLUTff (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Dec 2015 14:35:35 -0500
Content-Disposition: inline
In-Reply-To: <5677DBB6.3070008@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 21, 2015 at 12:00:06PM +0100, Daniel Borkmann wrote:
> On 12/18/2015 11:58 AM, Phil Sutter wrote:
> > This has a slight side-effect of not aborting when /proc/net/dev is
> > malformed, but OTOH stats are not parsed for uninteresting interfaces.
> >
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> > Changes since v1:
> > - Fix conflict resolution (sscan from 'buf' instead of 'ptr').
> [...]
> 
> Hmm, did you actually compile that?
> 
> The code is still the same as in v1 ... the only thing added is the "Changes since v1"
> description. ;)

Oh man. I certainly double-checked it, especially since I messed it up
the first time already. Quick forensics in my local clone revealed what
had happened:

1) Exported the V2 patch into a dedicated patch subdir.
2) ???
3) Edited the V1 patch in $TOPDIR and sent that out.

Face -> Desk.

Fix follows. :(

Thanks for reporting,

Phil
