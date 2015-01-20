From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Tue, 20 Jan 2015 10:36:40 -0800
Message-ID: <CAHA+R7PgJytCaeVz8aOyJ06JjKACMCrtp8oAnfuaSDSNJX8NvQ@mail.gmail.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
	<1421613815-6635-4-git-send-email-vadim4j@gmail.com>
	<CAPh34mdi+8wLaUY3ZBks40wbOtdzsbTrmuvsHivRouc9rs3gig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:50403 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbbATSgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 13:36:41 -0500
Received: by mail-qg0-f41.google.com with SMTP id q108so12936868qgd.0
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 10:36:40 -0800 (PST)
In-Reply-To: <CAPh34mdi+8wLaUY3ZBks40wbOtdzsbTrmuvsHivRouc9rs3gig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2015 at 2:29 AM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
> On 18 January 2015 at 21:43, Vadim Kochan <vadim4j@gmail.com> wrote:
>
> Hey Stephen,
>
> it is time to think about the format of the ss output - it starts to
> get unreadable. Neither humans nor scripts will parse the output. See
> the patch at the end,to get idea what I mean: who will understand
> "fallback_mode"? I don't want to blame someone - not at all, it is
> just one example. My proposal:
>

On the other hand, what blocks you from parsing the netlink message
by yourself? Don't get me wrong, I am not a fan of netlink, but
generally speaking, ss is not alone, too many scripts and applications
nowadays parse iproute2 tools output.
