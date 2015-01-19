From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Mon, 19 Jan 2015 16:50:09 +0200
Message-ID: <20150119145009.GA7743@angus-think.wlc.globallogic.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
 <1421613815-6635-4-git-send-email-vadim4j@gmail.com>
 <CAPh34mdJ7mjzueaX2qakoT=ODbHDLm4k-K_3Eg__6+s7ydf4Gg@mail.gmail.com>
 <20150119140421.GA1786@angus-think.wlc.globallogic.com>
 <CAPh34me7KFWnwgOaJmWZg3NxtzOZVce3VYShSy5PfeUkYkJcag@mail.gmail.com>
 <54BD1958.6030403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	Vadim Kochan <vadim4j@gmail.com>,
	netdev <netdev@vger.kernel.org>, stephen@networkplumber.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:62231 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbbASPAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 10:00:49 -0500
Received: by mail-we0-f180.google.com with SMTP id m14so6670942wev.11
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 07:00:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54BD1958.6030403@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2015 at 03:48:56PM +0100, Daniel Borkmann wrote:
> On 01/19/2015 03:28 PM, Hagen Paul Pfeifer wrote:
> >Hey Vadin,
> >
> >to make this short. We already discussed about changing the layout and
> >Stephen nacked this. My proposal was to key:value the output. Because
> >nearly all outputed data is already in this format - except the
> >congestion control algo, ts, sack and tx'ed data. Where I proposed
> >cc:<algo>. The key:value format has the advantages that the ordering
> >do not mather anymore, An python parser would be something like split
> >for whitespaces and later split for colon. Currently parsing this is a
> >mess, see [1].
> >
> >Anyway, the more clever idea is to add an json outputer like already
> >supported by some ss modules and get rid of this mess.
> 
> +1
> 
> I was also thinking in addition to json, that it might be useful to have
> an optional ncurses top-like mode in ss. The level of detail could be
> unfolded for a specific entry on demand, etc. I would not add it as a
> hard library requirement, but in case ncurses headers are detected by
> the configure script, it could be compiled in then. It's also easily
> changeable since there's no such requirement that the way data is being
> displayed needs to be stable for scripts.
> 
> >Hagen
> >
> >[1] https://github.com/hgn/captcp/blob/master/captcp.py#L4861

OK I will re-work series to do only refactoring/cleanups. And in future
I will keep in mind about any surprises for ss parsers.

Regards,
