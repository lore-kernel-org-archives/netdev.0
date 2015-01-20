From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Tue, 20 Jan 2015 13:09:51 +0200
Message-ID: <20150120110951.GA18551@angus-think.wlc.globallogic.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
 <1421613815-6635-4-git-send-email-vadim4j@gmail.com>
 <CAPh34mdi+8wLaUY3ZBks40wbOtdzsbTrmuvsHivRouc9rs3gig@mail.gmail.com>
 <54BE392F.2070804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	Vadim Kochan <vadim4j@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:38033 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378AbbATLUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 06:20:31 -0500
Received: by mail-wg0-f51.google.com with SMTP id l18so14541785wgh.10
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 03:20:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54BE392F.2070804@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2015 at 12:17:03PM +0100, Daniel Borkmann wrote:
> Hi Hagen,
> 
> On 01/20/2015 11:29 AM, Hagen Paul Pfeifer wrote:
> >On 18 January 2015 at 21:43, Vadim Kochan <vadim4j@gmail.com> wrote:
> ...
> >My proposal:
> >
> >1) support grouping. E.g. DCTCP could be separated in the following
> >manner. I.e. "dctcp:[ ce_state: %d, alpha: %d, ...  ]" or
> >"dctcp:ce_state.%d;alpha,%d" like the socket memory output.
> >     This makes it easier for humans and scripts to parse the output.
> >Since some time ss output is extended really extensive (especially
> >Eric make use of this). This is not the end and additional values are
> >added - make the current babylon even worse.
> 
> I have no strong opinion on this, but I also have a limited view on
> what applications try to parse ss output in general.
> 
> As mentioned, for human readability, we should implement a top-like
> display option which is allowed to have a rather 'instable' output
> by nature and levels of detail can be folded/unfolded on demand.

I think it would be good to have as option and output some default basic
info ?
> 
> >2) add a JSON formater as soon as possible to make the output
> >parseable. I would do this - it is required anyway.
> 
> Given the recent discussion on web10g, json output option might
> be very useful to provide i.e. when stats are being further extended.
> 
> Cheers,
> Daniel
