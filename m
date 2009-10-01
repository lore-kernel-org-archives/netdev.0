From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: kernel doc / docbook pdfdocs question
Date: Thu, 1 Oct 2009 08:57:07 -0700
Message-ID: <20091001085707.d74e3e79.randy.dunlap@oracle.com>
References: <8223.1254340776@jerryjeff.riw.enoyolf.org>
	<20090930173002.36da7ffd@s6510>
	<27289.1254375747@jerryjeff.riw.enoyolf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
To: Doug Maxey <dwm@enoyolf.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:49930 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbZJAP5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 11:57:44 -0400
In-Reply-To: <27289.1254375747@jerryjeff.riw.enoyolf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 01 Oct 2009 00:42:27 -0500 Doug Maxey wrote:

> 
> On Wed, 30 Sep 2009 17:30:02 PDT, Stephen Hemminger wrote:
> >On Wed, 30 Sep 2009 14:59:36 -0500
> >Doug Maxey <dwm@enoyolf.org> wrote:
> >
> >> 
> >> Randy,
> >> 
> >> This may be slightly off topic for this list, but it does involve an
> >> (as yet un-released) network driver. :)
> >> 
> >> Do you have any insight that could guide me toward a fix for an issue
> >> seen with some header file constructs when trying to generate a pdf
> >> docbook?
> >> 
> >
> >Why clutter docbook output (which is supposed to be about general kernel
> >API's) with output for data structures in one driver.
> 
> It would be a general mechanism, and it would be to document an API.
> There are other subsystems that use DECLARE_BITMAP() (e.g., scsi).
> Just none at the moment that attempt to describe such a member,
> possibly because there isn't a way to document it.  Dunno.  Build it
> and they will come.  There is one party that is interested anyway.
> 
> Finally did find where this was getting warned about / tossed, in
> kernel-doc itself. =)

Hi,

Sorry for the delayed reply.  I was away yesterday.

What did you find in kernel-doc?  Something like the
"cannot understand prototype" message or something else?

Features/support in kernel-doc is mostly added on an as-needed basis.
Now that you have provided a sample, I can try to add support for it,
but it's not exactly a high priority for me... or you can add support
for it to kernel-doc and send a patch for it.  :)


---
~Randy
