From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH iproute2 3/3] ip netns: Delete all netns
Date: Wed, 7 Jan 2015 16:00:43 -0800
Message-ID: <CAHA+R7M8OkCEoO+TFo06sFMsjzr4r1GrGRHSi+hqZNruhjPdOQ@mail.gmail.com>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
	<1420628662-9930-4-git-send-email-vadim4j@gmail.com>
	<54AD5458.6000400@hp.com>
	<20150107173640.GA19586@angus-think.lan>
	<20150107181112.GA24241@angus-think.lan>
	<54AD8BC3.2070609@hp.com>
	<20150107195517.GA4645@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brian Haley <brian.haley@hp.com>, netdev <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:56753 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbbAHAAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 19:00:44 -0500
Received: by mail-qa0-f49.google.com with SMTP id dc16so5113433qab.8
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 16:00:44 -0800 (PST)
In-Reply-To: <20150107195517.GA4645@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 11:55 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> So I think that do not allow to add netns "all" can be a solution, I'd
> like to hear from other people if it might be OK.
>

Nope, that would break existing scripts using "all" as a netns.
