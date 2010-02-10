From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and
 devices (v3)
Date: Wed, 10 Feb 2010 14:30:01 -0600
Message-ID: <20100210203001.GB23301@us.ibm.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
 <1265750713-15749-3-git-send-email-danms@us.ibm.com>
 <20100210172405.GB12251@us.ibm.com>
 <87pr4dgfdz.fsf@caffeine.danplanet.com>
 <4B7310AA.3090708@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Smith <danms@us.ibm.com>, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:55671 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755892Ab0BJUaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 15:30:24 -0500
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1AKSuph011787
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 13:28:57 -0700
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1AKU9YH100192
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 13:30:10 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1AKU71h006862
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 13:30:08 -0700
Content-Disposition: inline
In-Reply-To: <4B7310AA.3090708@cs.columbia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Oren Laadan (orenl@cs.columbia.edu):
> 
> 
> Dan Smith wrote:
> >SH> What exactly is this == 0 case?  Does it mean 'use inherited
> >SH> netns'?
> >
> >It means it wasn't in the checkpoint image to begin with, so yeah,
> >kinda.
> 
> Maybe it's time to define CKPT_OBJREF_NULL for that ?
> (to make it easy to fold, in a separate patch please)

Honestly that wouldn't be any more helpful.  Just a comment.  The
problem is with 0 having a different meaning for each type of
object, so 0 or CKPT_OBJREF_NULL is equally unhelpful imo :)

/* wasn't in the checkpoint image, use the netns of restarting task */

or somesuch

-serge
