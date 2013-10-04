From: Sami Kerola <kerolasa@iki.fi>
Subject: Re: [PATCH] ip: make -resolve addr to print names rather than addresses
Date: Fri, 4 Oct 2013 19:49:30 +0100
Message-ID: <CAG27Bk07G=Ojh0G7zAZAo8shVLeV016y1nE0o=-Kk6yUB5LsbA@mail.gmail.com>
References: <1380574908-9220-1-git-send-email-kerolasa@iki.fi>
	<20131004112530.1cab081c@nehalam.linuxnetplumber.net>
Reply-To: kerolasa@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:56288 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169Ab3JDStb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 14:49:31 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so4536241pab.4
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 11:49:30 -0700 (PDT)
In-Reply-To: <20131004112530.1cab081c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 October 2013 19:25, Stephen Hemminger <stephen@networkplumber.org> wrote:
> On Mon, 30 Sep 2013 22:01:48 +0100 Sami Kerola <kerolasa@iki.fi> wrote:
>
>> As a system admin I occasionally want to be able to check that all
>> interfaces has a name in DNS or /etc/hosts file.
>
> This shouldn't be the default. It will change the result that user's expect now.

Doesn't the format_host() print exactly the same output as before,
unless -r is defined.
I intended resolution to happen when

ip -r addr

is used, but not when the -r is not specified. Or did I somehow messed
up the logic?

-- 
Sami Kerola
http://www.iki.fi/kerolasa/
