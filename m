From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Wed, 21 Jan 2015 09:54:02 +0100
Message-ID: <CAPh34me2T6+GbK3GTwir3kraa6eB-rMFkP_YaHN7Oaeyza6PVw@mail.gmail.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
	<1421613815-6635-4-git-send-email-vadim4j@gmail.com>
	<CAPh34mdi+8wLaUY3ZBks40wbOtdzsbTrmuvsHivRouc9rs3gig@mail.gmail.com>
	<CAHA+R7PgJytCaeVz8aOyJ06JjKACMCrtp8oAnfuaSDSNJX8NvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:45632 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbbAUIyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 03:54:05 -0500
Received: by mail-lb0-f182.google.com with SMTP id l4so12617503lbv.13
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 00:54:02 -0800 (PST)
In-Reply-To: <CAHA+R7PgJytCaeVz8aOyJ06JjKACMCrtp8oAnfuaSDSNJX8NvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

20 January 2015 at 19:36, Cong Wang <cwang@twopensource.com> wrote:

> On the other hand, what blocks you from parsing the netlink message
> by yourself? Don't get me wrong, I am not a fan of netlink, but
> generally speaking, ss is not alone, too many scripts and applications
> nowadays parse iproute2 tools output.

Agree, thus the proposal:

1) *new* ss values are "prefixed" by an name to make it possible that
*humans* can understand the value ("make ss output human readable").
Concrete rule for scalar value: key:value. Concrete rule for list of
values: subsystem:(key1:val1,key1:val2). The actual ss output is
nearly formatted matching these rules. E.g. see socket memory for list
formated output. Sure, there are values like SACK that do not need any
prefix and can assumed to be known.

2) add JSON format for scripts and tools.

Hagen
