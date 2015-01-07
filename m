From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 3/3] ip netns: Delete all netns
Date: Wed, 7 Jan 2015 21:55:17 +0200
Message-ID: <20150107195517.GA4645@angus-think.lan>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
 <1420628662-9930-4-git-send-email-vadim4j@gmail.com>
 <54AD5458.6000400@hp.com>
 <20150107173640.GA19586@angus-think.lan>
 <20150107181112.GA24241@angus-think.lan>
 <54AD8BC3.2070609@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:44447 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbbAGUFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 15:05:44 -0500
Received: by mail-la0-f52.google.com with SMTP id hs14so5523147lab.11
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 12:05:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54AD8BC3.2070609@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2015 at 02:40:51PM -0500, Brian Haley wrote:
> On 01/07/2015 01:11 PM, Vadim Kochan wrote:
> > On Wed, Jan 07, 2015 at 07:36:40PM +0200, Vadim Kochan wrote:
> >> On Wed, Jan 07, 2015 at 10:44:24AM -0500, Brian Haley wrote:
> >>> On 01/07/2015 06:04 AM, Vadim Kochan wrote:
> >>>> From: Vadim Kochan <vadim4j@gmail.com>
> >>>>
> >>>> Allow delete all namespace names by:
> >>>>
> >>>>     $ ip netns del all
> >>>
> >>> So I can still create a namespace called 'all', but can't exec in it or delete
> >>> it independently with this change.  Perhaps you need to block that as well?
> >>> Unless there's some other patch I'm missing?
> >>>
> >>> -Brian
> >> Hm, I did not take it into account ...
> >> I will look if I can find another way ...
> >>
> >> Thanks,
> > 
> > what about this ?
> > 
> >     $ ip netns exec / ip link
> >     $ ip netns del /
> > 
> > so it make a sense to be as root directory of bound ns names in /var/run/netns/ ?
> > what do you think ?
> 
> I think using / is confusing.  And something like -a[ll] as an option doesn't
> seem right either.
> 
> Or you just trap the name "all" in the add case and don't allow it.
> 
> Just my opinion.
> 
> -Brian

So I think that do not allow to add netns "all" can be a solution, I'd
like to hear from other people if it might be OK.

Thanks,
