From: "Denys" <denys@visp.net.lb>
Subject: Re: [Bugme-new] [Bug 8325] New: -j REDIRECT --to-ports 1000-1009, always first choosen
Date: Mon, 16 Apr 2007 08:26:35 +0300
Message-ID: <20070416052535.M41456@visp.net.lb>
References: <200704132053.l3DKrC9X000466@fire-2.osdl.org> <20070413144702.8ebf1cfe.akpm@linux-foundation.org> <462305C1.9030007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Patrick McHardy <kaber@trash.net>, wijata@nec-labs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:53540 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810AbXDPF1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 01:27:21 -0400
In-Reply-To: <462305C1.9030007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, i will put my IMHO, since i am using it too.

I guess it can be useful for load-balancing scenario.
Is there way to provide both ways?
Thinking... 60% done, But maybe this can be done over -m statistic already

On Mon, 16 Apr 2007 07:12:33 +0200, Patrick McHardy wrote
> Andrew Morton wrote:
> > On Fri, 13 Apr 2007 13:53:12 -0700
> > bugme-daemon@bugzilla.kernel.org wrote:
> > 
> > 
> >>http://bugzilla.kernel.org/show_bug.cgi?id=8325
> >>
> >>           Summary: -j REDIRECT --to-ports 1000-1009, always first choosen
> >>    Kernel Version: 2.6.19-1.2911.fc6PAE 2.6.19-gentoo-r4
> >>            Status: NEW
> >>          Severity: normal
> >>             Owner: networking_netfilter-iptables@kernel-bugs.osdl.org
> >>         Submitter: wijata@nec-labs.com
> >>
> >>
> >>Most recent kernel where this bug did *NOT* occur:
> >>Distribution: FC6, gentoo
> >>Hardware Environment:
> >>Software Environment:
> >>Problem Description:
> >>
> >>Steps to reproduce:
> >>Try redirecting to range of ports with iptables, kernel(?) will always 
redirect 
> >>to first port from given range.
> 
> It will use a different port if there is a clash (a connection with the
> same identity already exists). I'm guessing you're expecting that it
> will use the ports in order. We might be able to change that, but I
> don't really see a case where it would make sense. Please describe what
> you're trying to do.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

