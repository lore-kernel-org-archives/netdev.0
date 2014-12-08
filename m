From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH flow-net-next] net: flow: Correct spelling of action
Date: Mon, 8 Dec 2014 12:47:18 +0900
Message-ID: <20141208034715.GA606@vergenet.net>
References: <1418001295-2389-1-git-send-email-simon.horman@netronome.com>
 <54850093.7050900@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:44282 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851AbaLHDr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 22:47:28 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so4395829pab.20
        for <netdev@vger.kernel.org>; Sun, 07 Dec 2014 19:47:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54850093.7050900@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 07, 2014 at 05:36:19PM -0800, John Fastabend wrote:
> On 12/07/2014 05:14 PM, Simon Horman wrote:
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > ---
> >  include/uapi/linux/if_flow.h | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
> > index 25aa744..9255990 100644
> > --- a/include/uapi/linux/if_flow.h
> > +++ b/include/uapi/linux/if_flow.h
> > @@ -356,7 +356,7 @@ enum {
> >   * @uid unique identifier for flow
> >   * @priority priority to execute flow match/action in table
> >   * @match null terminated set of match uids match criteria
> > - * @actoin null terminated set of action uids to apply to match
> > + * @action null terminated set of action uids to apply to match
> >   *
> >   * Flows must match all entries in match set.
> >   */
> > 
> 
> Great thanks Simon! Also I've added a bit so we can
> distinguish between INGRESS pipelines and EGRESS pipelines
> and a bunch of fixes to the netlink processing to check the
> lengths correctly. I'll push those to my tree in the next day or
> so. I'm also porting this to rocker switch now which I hope
> should be ready in the next week for submitting.
> 
> Just to be clear this is against my git tree @
> 
> 	https://github.com/jrfastab/flow-net-next/

Yes, that is right.

Feel free to squash it into existing patches if you prefer.
