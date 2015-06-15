From: Zack Weinberg <zackw@panix.com>
Subject: Re: "ip netns create" hangs forever, spamming console with
 "unregister_netdevice: waiting for lo to become free"
Date: Mon, 15 Jun 2015 13:34:05 -0400
Message-ID: <CAKCAbMjpRyfZ5OjY6SEygJfmo4AxVPsd+rjMJP1UWS8aQT-HEg@mail.gmail.com>
References: <CAKCAbMgkpFMX7cQS=c3eD802aKTWesCv1TW7n8mtBvqLF0BN8Q@mail.gmail.com>
	<CAKCAbMj9tKg95mNyUQZxRHxtTTCb2BQxYLehtA8XjD7Sf_t1Cw@mail.gmail.com>
	<CANr6G5zVPaP1N-9rQ=PCn9-NJGd7QONmv_HO6OqJs19yBWCyFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbackend.panix.com ([166.84.1.89]:60107 "EHLO
	mailbackend.panix.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754514AbbFOReH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 13:34:07 -0400
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by mailbackend.panix.com (Postfix) with ESMTPSA id CDE71132B7
	for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 13:34:06 -0400 (EDT)
Received: by wiga1 with SMTP id a1so85236353wig.0
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 10:34:05 -0700 (PDT)
In-Reply-To: <CANr6G5zVPaP1N-9rQ=PCn9-NJGd7QONmv_HO6OqJs19yBWCyFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 7, 2015 at 11:56 PM, Joe Stringer <joestringer@nicira.com> wrote:
>
> Hi Zack, have you had any further development on this issue?

Sorry for the delay.  The only additional piece of information I have
for you is that
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1403152 may be
another report of the same bug, or a closely-related one.

I am fairly sure this would be easy to fix if someone could just come
up with a reliable reproducer, but I've had no further luck myself,
although that Ubuntu bug did give me an idea -- specifically, it might
be necessary to make a lot of outbound connections from within a
network namespace to trigger the problem.  I am juggling several other
issues right now and haven't had time to follow up on that idea.

zw
