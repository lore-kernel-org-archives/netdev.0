From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Mon, 19 Jan 2015 16:28:03 +0200
Message-ID: <20150119142803.GA5549@angus-think.wlc.globallogic.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
 <1421613815-6635-4-git-send-email-vadim4j@gmail.com>
 <CAPh34mdJ7mjzueaX2qakoT=ODbHDLm4k-K_3Eg__6+s7ydf4Gg@mail.gmail.com>
 <20150119140421.GA1786@angus-think.wlc.globallogic.com>
 <CAPh34me7KFWnwgOaJmWZg3NxtzOZVce3VYShSy5PfeUkYkJcag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:64806 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbbASOim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 09:38:42 -0500
Received: by mail-wg0-f41.google.com with SMTP id a1so10065230wgh.0
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 06:38:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAPh34me7KFWnwgOaJmWZg3NxtzOZVce3VYShSy5PfeUkYkJcag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2015 at 03:28:21PM +0100, Hagen Paul Pfeifer wrote:
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
> 
> Hagen
> 
> 
> [1] https://github.com/hgn/captcp/blob/master/captcp.py#L4861

Seems these patches will break your script at least for memory info
output.

I am thinking may be 1st of all it is better to make output in json
format and after this trying to make changes with human readability.

What do you think ?

Regards,
Vadim Kochan
