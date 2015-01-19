From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Mon, 19 Jan 2015 16:01:22 +0100
Message-ID: <CAPh34mcbE9uT3DBPe9jDCT7JuXBbnO55dKuxkodszrYTGKpovw@mail.gmail.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
	<1421613815-6635-4-git-send-email-vadim4j@gmail.com>
	<CAPh34mdJ7mjzueaX2qakoT=ODbHDLm4k-K_3Eg__6+s7ydf4Gg@mail.gmail.com>
	<20150119140421.GA1786@angus-think.wlc.globallogic.com>
	<CAPh34me7KFWnwgOaJmWZg3NxtzOZVce3VYShSy5PfeUkYkJcag@mail.gmail.com>
	<20150119142803.GA5549@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:56604 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbbASPBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 10:01:23 -0500
Received: by mail-la0-f42.google.com with SMTP id ms9so7046407lab.1
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 07:01:22 -0800 (PST)
In-Reply-To: <20150119142803.GA5549@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 January 2015 at 15:28, Vadim Kochan <vadim4j@gmail.com> wrote:

> I am thinking may be 1st of all it is better to make output in json
> format and after this trying to make changes with human readability.
>
> What do you think ?

Mhh, if an JSON outputer is also provided a prioi *I* had no problems
with an incompatible change. It is awful to parse the current output.
*But* I am not sure if this opinion is shared by Stephen too. We
probably break several scripts/applications with this change. Breaking
the output *and* do not provide an stable alternative (JSON) is bad.

+1 for JSON (which is not that hard to implement)

hgn
