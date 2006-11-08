From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: RE: [PATCH 3/3] mlsxfrm: Various fixes
Date: Wed, 08 Nov 2006 12:34:08 -0500
Message-ID: <1163007248.12241.58.camel@moss-spartans.epoch.ncsc.mil>
References: <000601c70343$02fa9fe0$cc0a010a@tcssec.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul.moore@hp.com>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zombie.ncsc.mil ([144.51.88.131]:46753 "EHLO jazzdrum.ncsc.mil")
	by vger.kernel.org with ESMTP id S1754612AbWKHRgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 12:36:18 -0500
To: vyekkirala@TrustedCS.com
In-Reply-To: <000601c70343$02fa9fe0$cc0a010a@tcssec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-08 at 08:34 -0600, Venkat Yekkirala wrote:
> > Such duplication can occur among the initial SIDs.
> 
> For some reason I thought that could happen between an initial SID
> and a non-initial SID.

I think only in the case where a non-initial SID has been invalidated by
policy reload that renders its context illegal and is thus remapped to
the unlabeled SID.  

> >  Not sure 
> > though when
> > that would apply here,
> 
> It could apply to xfrms if they happen to be using the context
> represented by any of the initial SIDs.

Which would happen when?  

> > and it would only apply if both SIDs 
> > were initial
> > SIDs.
> 
> OK. Will narrow the full context comparison to just this case.

What's the harm from just using the SID comparison and allowing for the
possibility that there might be a few duplicates in rare circumstances?
Does it break any assumptions in the rest of the logic?

-- 
Stephen Smalley
National Security Agency

