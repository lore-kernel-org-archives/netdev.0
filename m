From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: ipv6: Make address flushing on ifdown optional -
 v2
Date: Tue, 3 Feb 2015 01:18:11 +0100
Message-ID: <20150203011811.12d69803@uryu.home.lan>
References: <1422504065-17445-1-git-send-email-dsahern@gmail.com>
	<20150203001057.3e0e22b2@uryu.home.lan>
	<54D0124C.70202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hannes Frederic Sowa <hannes@redhat.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:64971 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965178AbbBCASb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 19:18:31 -0500
Received: by mail-ie0-f175.google.com with SMTP id ar1so21543624iec.6
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 16:18:30 -0800 (PST)
In-Reply-To: <54D0124C.70202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 02 Feb 2015 17:11:56 -0700
David Ahern <dsahern@gmail.com> wrote:

> On 2/2/15 4:10 PM, Stephen Hemminger wrote:
> > Checkpatch complains about space before tab, which could be your
> > mailer mangling the patch.
> 
> Yes, found that a couple of days ago. I use 'git send-email' to send the 
> patches, and I have a pre-commit hook to run checkpatch.pl. Perhaps I 
> goofed something in the recent latptop transitions.
> 
> >
> > This should probably go into the netconf netlink message as well.
> >
> 
> Not sure I understand this point. Can you point me to a code reference 
> to look up?

Look at how forwarding flag is propagated already via NETCONFA_FORWARDING.
