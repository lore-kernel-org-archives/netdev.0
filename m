From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH 2/7] dccp ccid-3: Simplified handling of TX states
Date: Wed, 30 Jul 2008 06:54:48 +1200
Message-ID: <5640c7e00807291154q56b2d1f0q49b7903f998f86ed@mail.gmail.com>
References: <1217268843-19667-1-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1217268843-19667-2-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1217268843-19667-3-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.238]:10855 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbYG2Syt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 14:54:49 -0400
Received: by wr-out-0506.google.com with SMTP id 69so7722wri.5
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 11:54:48 -0700 (PDT)
In-Reply-To: <1217268843-19667-3-git-send-email-gerrit@erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2008 at 6:13 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Since CCIDs are only used during the established phase of a connection,
> they have very little internal state; this specifically reduces to:
>
>  * "no packet sent" if and only if s == 0, for the TX packet size s;
>
>  * when the first packet has been sent (i.e. `s' > 0), the question is whether
>   or not feedback has been received:
>   - if a feedback packet is received, "feedback = yes" is set,
>   - if the nofeedback timer expires,  "feedback = no"  is set.
>
> Thus the CCID only needs to remember state about whether or not feedback
> has been received. This is now implemented using a boolean flag, which is
> toggled when a feedback packet arrives or the nofeedback timer expires.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
