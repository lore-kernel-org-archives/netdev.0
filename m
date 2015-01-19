From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Mon, 19 Jan 2015 15:28:21 +0100
Message-ID: <CAPh34me7KFWnwgOaJmWZg3NxtzOZVce3VYShSy5PfeUkYkJcag@mail.gmail.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
	<1421613815-6635-4-git-send-email-vadim4j@gmail.com>
	<CAPh34mdJ7mjzueaX2qakoT=ODbHDLm4k-K_3Eg__6+s7ydf4Gg@mail.gmail.com>
	<20150119140421.GA1786@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:44212 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbbASO2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 09:28:23 -0500
Received: by mail-la0-f43.google.com with SMTP id q1so13826416lam.2
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 06:28:21 -0800 (PST)
In-Reply-To: <20150119140421.GA1786@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Vadin,

to make this short. We already discussed about changing the layout and
Stephen nacked this. My proposal was to key:value the output. Because
nearly all outputed data is already in this format - except the
congestion control algo, ts, sack and tx'ed data. Where I proposed
cc:<algo>. The key:value format has the advantages that the ordering
do not mather anymore, An python parser would be something like split
for whitespaces and later split for colon. Currently parsing this is a
mess, see [1].

Anyway, the more clever idea is to add an json outputer like already
supported by some ss modules and get rid of this mess.

Hagen


[1] https://github.com/hgn/captcp/blob/master/captcp.py#L4861
