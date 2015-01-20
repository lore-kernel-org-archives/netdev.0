From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Tue, 20 Jan 2015 12:17:03 +0100
Message-ID: <54BE392F.2070804@redhat.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com> <1421613815-6635-4-git-send-email-vadim4j@gmail.com> <CAPh34mdi+8wLaUY3ZBks40wbOtdzsbTrmuvsHivRouc9rs3gig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41424 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752738AbbATLRS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2015 06:17:18 -0500
In-Reply-To: <CAPh34mdi+8wLaUY3ZBks40wbOtdzsbTrmuvsHivRouc9rs3gig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hagen,

On 01/20/2015 11:29 AM, Hagen Paul Pfeifer wrote:
> On 18 January 2015 at 21:43, Vadim Kochan <vadim4j@gmail.com> wrote:
...
> My proposal:
>
> 1) support grouping. E.g. DCTCP could be separated in the following
> manner. I.e. "dctcp:[ ce_state: %d, alpha: %d, ...  ]" or
> "dctcp:ce_state.%d;alpha,%d" like the socket memory output.
>      This makes it easier for humans and scripts to parse the output.
> Since some time ss output is extended really extensive (especially
> Eric make use of this). This is not the end and additional values are
> added - make the current babylon even worse.

I have no strong opinion on this, but I also have a limited view on
what applications try to parse ss output in general.

As mentioned, for human readability, we should implement a top-like
display option which is allowed to have a rather 'instable' output
by nature and levels of detail can be folded/unfolded on demand.

> 2) add a JSON formater as soon as possible to make the output
> parseable. I would do this - it is required anyway.

Given the recent discussion on web10g, json output option might
be very useful to provide i.e. when stats are being further extended.

Cheers,
Daniel
