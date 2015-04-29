From: Felix Janda <felix.janda@posteo.de>
Subject: Re: [PATCH iproute2] Use PATH_MAX instead of MAXPATHLEN
Date: Wed, 29 Apr 2015 18:52:05 +0200
Message-ID: <20150429165205.GA1364@euler>
References: <20150425203327.GA9433@euler>
 <20150427091334.01323146@urahara>
 <55400DE7.9080501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.posteo.de ([89.146.194.165]:47604 "EHLO mx02.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753599AbbD2QwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2015 12:52:15 -0400
Content-Disposition: inline
In-Reply-To: <55400DE7.9080501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
> On 27/04/15 09:13, Stephen Hemminger wrote:
> > On Sat, 25 Apr 2015 22:33:28 +0200
> > Felix Janda <felix.janda@posteo.de> wrote:
> > 
> >> They are equivalent but the former is more common. PATH_MAX is
> >> specified by POSIX and needs <limits.h> while MAXPATHLEN has BSD
> >> origin and needs <sys/param.h>.
> >>
> >> PATH_MAX has already been in use in misc/lnstat.h.
> >>
> >> Signed-off-by: Felix Janda <felix.janda@posteo.de>
> > 
> > Iproute2 is intended for use on Linux.
> > It makes more sense to align with Posix than using leftover
> > BSD stuff. Therefore I don't see any point in doing this.
> 
> My reading from Felix's commit message is that he is attempting to do
> exactly that: conform to POSIX rather than BSD, which seems to be the
> direction you are also suggesting here.
> -- 
> Florian

This is correct. (In fact I misread the end of Stephen's message,
thought that the patch was merged and wanted to thank for that.)

Felix
