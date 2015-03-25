From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH] iproute2: enhance addr label validation
Date: Wed, 25 Mar 2015 09:22:53 +0900
Message-ID: <20150325002251.GE23124@vergenet.net>
References: <550DD13D.90009@tekcomms.com>
 <20150323011522.GB20755@vergenet.net>
 <55101D07.6090301@tekcomms.com>
 <55103487.5070903@tekcomms.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemming@brocade.com>,
	Vadim Kochan <vadim4j@gmail.com>
To: Joe Harvell <joe.harvell@tekcomms.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:36023 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbbCYAXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 20:23:04 -0400
Received: by pdbcz9 with SMTP id cz9so9630065pdb.3
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 17:23:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55103487.5070903@tekcomms.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

On Mon, Mar 23, 2015 at 10:43:03AM -0500, Joe Harvell wrote:
> >
> >>Hi Joe,
> >>
> >>On Sat, Mar 21, 2015 at 03:14:53PM -0500, Joe Harvell wrote:
> >>>The ip addr command today rejects address labels that would break
> >>>ifconfig.  However, it allows some labels which still break it. Enhance
> >>>enforcement to reject all known incompatible labels, and allow the
> >>>existing -force option to allow someone to use a label even if it is
> >>>not
> >>>ifconfig compatible
> >>I am concerned this will break existing users who are relying on setting
> >>labels that would now be rejected without using -force.
> >>
> >[snip]
> >
> >Simon,
> >
> >Good point.  I propose the following:
> >
> >When a label is specified without -force, and that label begins with the
> >interface
> >name but is followed by something other than a colon, accept the label but
> >emit
> >a warning message indicating this label is incompatible with ifconfig and
> >that later
> >versions of the 'ip address' command may reject it.  This message can also
> >indicate
> >that -force can be specified to explicitly indicate a label that is non
> >ifconfig compatible
> >is desired.
> >
> >At some point in the future, the behavior could then be changed to reject
> >such labels.
> >
> >What do you think?
> >
> >---
> >Joe
>
> Ok, I made the changes I propose above, and have pushed them to
> 'git@github.com:jharvell/iproute2.git addr-label-noncompat' with a new
> signoff commit (303f46819883d4c808974629a6d3515102c5c0d0) that summarizes
> all the changes from master.  But I'm not sure what I'm supposed to do
> with respect to the patch in patchwork to designate that I want the new
> code to be merged instead of before the change.  Do I reject this patch
> request and submit another one?  Do I send an email with the same subject
> as this one with the new patch against master?

To some extent this is up to Stephen, who is the maintainer.
But I expect the following should be close to the mark:

1. If you new patch has the same title as the previous patch then
   you can post it as [PATCH v2] and it should be fairly clear that
   it supersedes the previous version.

2. If you new patch has a different title then there could be a note
  in response to it noting that it has been superseded. In effect your
  previous email is such a note.
