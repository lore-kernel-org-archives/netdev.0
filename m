From: Luke Hutchison <luke.hutch@gmail.com>
Subject: Re: Networking hangs when too many parallel requests are made at once
Date: Tue, 9 Nov 2010 17:38:38 -0500
Message-ID: <AANLkTi=LGx2mbYT5gRMV0izg5=KY7pCKOuXnwPRNQDMK@mail.gmail.com>
References: <AANLkTikuCj=saH34dyO6xnU-y8rWv63hJaqowZ0ACLzk@mail.gmail.com>
 <AANLkTinRo_ozWFCYYqanOh0YrTJ6+KadutG2j7T726dY@mail.gmail.com>
 <4CD99E20.4060307@candelatech.com> <AANLkTinz6C4s3wX7t6CsE2bzZ2adCoi0RAcqvpEFE2GV@mail.gmail.com>
 <4CD9B09B.8040906@candelatech.com> <AANLkTinu4=Ox_vA_yr7vbdbcqr4P7oS+zMX_yaXhK4E9@mail.gmail.com>
 <4CD9C7E2.6050909@candelatech.com> <AANLkTi=qgJcBUdhDpV8QdPPUO1o7QjZLUj07_C1B9Ygg@mail.gmail.com>
 <4CD9CB44.4030206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:38449 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481Ab0KIWjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 17:39:43 -0500
Received: by gyh4 with SMTP id 4so4765416gyh.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 14:39:43 -0800 (PST)
In-Reply-To: <4CD9CB44.4030206@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 9, 2010 at 5:29 PM, Ben Greear <greearb@candelatech.com> wrote:
> If you get all names resolved with your caching name-server, can you then
> open the browser tabs w/out problem?

This is hard to test, because to get all the same domain names
resolved for all resources on all pages, I have to successfully open
all the pages once first.  Even opening the pages a few seconds apart
seems to break things quite frequently.  And there is a period where
the connection starts acting up but is not hard locked up, and it's
hard to know at that point if it's the connection or the individual
website.  The only way I can think of of reliably triggering this 100%
of the time is to open a bunch of browser tabs all at the same time --
and that hangs the dns caching server's requests too.

> Have you tried setting all your browser tabs to simple low-bandwidth pages (no ads being
> served from various hosts, etc) to see if that works?

Not exactly, but I have one browser window with about 20 Wikipedia
articles open, and not all of them load (some get stalled until they
time out).  I think this serves the same purpose as your suggested
test, because Wikipedia doesn't draw from many external domains.

> Maybe you are just flooding the network so hard that responses are being
> dropped?

Yes, but you pointed out earlier that you routinely test with
thousands of TCP connections, and we're only talking about 20-30
browser tabs here, maybe a few thousand HTTP requests at most.  Also,
this used to work fine on old Fedora kernels and no longer works with
more recent kernels.

Thanks,
Luke
