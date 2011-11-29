From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: ebtables on a stick
Date: Tue, 29 Nov 2011 04:48:25 -0600
Message-ID: <925A849792280C4E80C5461017A4B8A2A048C2@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com> <20111128143901.GA589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A0488A@mail733.InfraSupportEtc.com> <20111128153002.GB589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048BC@mail733.InfraSupportEtc.com> <20111129102338.GF589422@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Lamparter" <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:34717 "EHLO
	mail.infrasupport.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919Ab1K2Ksb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 05:48:31 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well this seems like the only way to get done what I need, so if our
votes count, we'll vote to leave it in.  Let me get some sleep and I'll
try it and report back here later.  

- Greg



-----Original Message-----
From: David Lamparter [mailto:equinox@diac24.net] 
Sent: Tuesday, November 29, 2011 4:24 AM
To: Greg Scott
Cc: David Lamparter; netdev@vger.kernel.org
Subject: Re: ebtables on a stick

On Tue, Nov 29, 2011 at 04:05:18AM -0600, Greg Scott wrote:
> > We already had this discussion in July.
> >
> > "ip neigh add proxy" is independent of /proc/.../proxy_arp.
> 
> We did discuss this back in July but never finished.  I posted a bunch
> of questions about "ip neigh add proxy" because I haven't seen much in
> the way of documentation.  When nobody answered, I left it alone for a
> while.  
> 
> I found a discussion starting here:
> http://lkml.indiana.edu/hypermail/linux/kernel/0110.2/0523.html
> 
> where some of the kernel folks are suggesting "ip neigh add proxy" is
> deprecated.  By now that discussion is 10 years old and it apparently
is
> still around.  But for how long?

While the feature is still around after 10 years, Alexey isn't touching
the network stack much anymore. Funny, that.

> Appendix B of this 2007 document, http://linux-ip.net/html/index.html,
> by Martin Brown also says "ip neigh add proxy" is deprecated.
>
> So now, in addition to my paranoia about proxy ARP in general, I have
> this fear I will build a bunch of scripting around "ip neigh add
proxy"
> only to find it's gone in a future kernel, leaving me in a world of
hurt
> again.
>
> So humor me and convince me that "ip neigh add" is not on the chopping
> block so I can try it with a little bit of confidence.

I'll humor myself instead. I'm shipping this as a feature to customers,
so if it comes up for chopping I'll have to maintain it myself
worst-case.

(I wasn't actually aware that this is supposed to be deprecated. Yes,
it's buggy in that you need "arp" to show the entries, but that's exacly
that - a low-severity bug.)


-David
