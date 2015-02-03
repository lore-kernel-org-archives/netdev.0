From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: ipv6: Make address flushing on ifdown optional -
 v2
Date: Tue, 3 Feb 2015 09:27:57 -0800
Message-ID: <20150203092757.72b0ad66@urahara>
References: <1422504065-17445-1-git-send-email-dsahern@gmail.com>
	<20150203001057.3e0e22b2@uryu.home.lan>
	<54D0124C.70202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hannes Frederic Sowa <hannes@redhat.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:56562 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965362AbbBCR2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 12:28:03 -0500
Received: by mail-pa0-f45.google.com with SMTP id et14so98764486pad.4
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 09:28:02 -0800 (PST)
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
> 
> Though that did remind me that I should add a blurb in 
> Documentation/networking/ip-sysctl.txt.
> 
> David

Never mind, actually NETCONFA stuff is mostly for case where
listener needs to know how to handle offload, and this  doesn't
impact that.
