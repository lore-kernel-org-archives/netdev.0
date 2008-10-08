From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Wed, 8 Oct 2008 14:56:28 +0200
Message-ID: <20081008125628.GD28783@1wt.eu>
References: <20081008081109.GA25342@1wt.eu> <48ECA4AC.1010101@openvz.org> <20081008122645.GB28783@1wt.eu> <48ECA85D.1050809@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4663 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694AbYJHM4d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 08:56:33 -0400
Content-Disposition: inline
In-Reply-To: <48ECA85D.1050809@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 04:32:29PM +0400, Pavel Emelyanov wrote:
> Willy Tarreau wrote:
> > Hi Pavel,
> > 
> > On Wed, Oct 08, 2008 at 04:16:44PM +0400, Pavel Emelyanov wrote:
> >>> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> >>> index d0437f3..0e23062 100644
> >>> --- a/include/linux/sysctl.h
> >>> +++ b/include/linux/sysctl.h
> >>> @@ -435,6 +435,7 @@ enum
> >>>  	NET_TCP_ALLOWED_CONG_CONTROL=123,
> >>>  	NET_TCP_MAX_SSTHRESH=124,
> >>>  	NET_TCP_FRTO_RESPONSE=125,
> >>> +	NET_TCP_SIMULT_CONNECT=126,
> >> Minor - sysctl syscall (as long as numbers and ->strategy callbacks) are
> >> about to be removed some time, so new sysctls are to be CTL_UNNUMBERED.
> > 
> > I noticed that one in the two latest UDP sysctls, but was not aware of the
> > rules related to its use. Given the number of unconverted sysctls, is it
> > worth changing it now ?
> 
> Sorry, I don't get you here. Sysctls are not supposed to get converted,
> the intention is just to a) stop adding new sysctls with strategies and

> b) drop all the existing strategies in the future.

If existing declarations eventually get changed, that's what I call a
conversion :-)

OK I get you here. The patch will be resent with CTL_UNNUMBERED if there is
an agreement to get it merged.

Regards,
Willy

