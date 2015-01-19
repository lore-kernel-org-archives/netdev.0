From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Mon, 19 Jan 2015 15:48:56 +0100
Message-ID: <54BD1958.6030403@redhat.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com> <1421613815-6635-4-git-send-email-vadim4j@gmail.com> <CAPh34mdJ7mjzueaX2qakoT=ODbHDLm4k-K_3Eg__6+s7ydf4Gg@mail.gmail.com> <20150119140421.GA1786@angus-think.wlc.globallogic.com> <CAPh34me7KFWnwgOaJmWZg3NxtzOZVce3VYShSy5PfeUkYkJcag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev <netdev@vger.kernel.org>,
	stephen@networkplumber.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53013 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751225AbbASOtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2015 09:49:08 -0500
In-Reply-To: <CAPh34me7KFWnwgOaJmWZg3NxtzOZVce3VYShSy5PfeUkYkJcag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2015 03:28 PM, Hagen Paul Pfeifer wrote:
> Hey Vadin,
>
> to make this short. We already discussed about changing the layout and
> Stephen nacked this. My proposal was to key:value the output. Because
> nearly all outputed data is already in this format - except the
> congestion control algo, ts, sack and tx'ed data. Where I proposed
> cc:<algo>. The key:value format has the advantages that the ordering
> do not mather anymore, An python parser would be something like split
> for whitespaces and later split for colon. Currently parsing this is a
> mess, see [1].
>
> Anyway, the more clever idea is to add an json outputer like already
> supported by some ss modules and get rid of this mess.

+1

I was also thinking in addition to json, that it might be useful to have
an optional ncurses top-like mode in ss. The level of detail could be
unfolded for a specific entry on demand, etc. I would not add it as a
hard library requirement, but in case ncurses headers are detected by
the configure script, it could be compiled in then. It's also easily
changeable since there's no such requirement that the way data is being
displayed needs to be stable for scripts.

> Hagen
>
> [1] https://github.com/hgn/captcp/blob/master/captcp.py#L4861
