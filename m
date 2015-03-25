From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH] iproute2: enhance addr label validation
Date: Wed, 25 Mar 2015 09:23:11 +0900
Message-ID: <20150325002309.GF23124@vergenet.net>
References: <550DD13D.90009@tekcomms.com>
 <20150323011522.GB20755@vergenet.net>
 <55101D07.6090301@tekcomms.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemming@brocade.com>,
	Vadim Kochan <vadim4j@gmail.com>
To: Joe Harvell <joe.harvell@tekcomms.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36498 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbbCYAXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 20:23:22 -0400
Received: by padcy3 with SMTP id cy3so9680662pad.3
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 17:23:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55101D07.6090301@tekcomms.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

On Mon, Mar 23, 2015 at 09:02:47AM -0500, Joe Harvell wrote:
> >Hi Joe,
> >
> >On Sat, Mar 21, 2015 at 03:14:53PM -0500, Joe Harvell wrote:
> >>The ip addr command today rejects address labels that would break
> >>ifconfig.  However, it allows some labels which still break it. Enhance
> >>enforcement to reject all known incompatible labels, and allow the
> >>existing -force option to allow someone to use a label even if it is not
> >>ifconfig compatible
> >I am concerned this will break existing users who are relying on setting
> >labels that would now be rejected without using -force.
> >
> [snip]
> 
> Simon,
> 
> Good point.  I propose the following:
> 
> When a label is specified without -force, and that label begins with the
> interface name but is followed by something other than a colon, accept
> the label but emit a warning message indicating this label is
> incompatible with ifconfig and that later versions of the 'ip address'
> command may reject it.  This message can also indicate that -force can be
> specified to explicitly indicate a label that is non ifconfig compatible
> is desired.
> 
> At some point in the future, the behavior could then be changed to reject
> such labels.
> 
> What do you think?

That sounds entirely reasonable to me.
