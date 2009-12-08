From: Olaf van der Spek <olafvdspek@gmail.com>
Subject: Re: [PATCH 1/2] syncookies: print synflood warning if syn queue is
	full
Date: Tue, 8 Dec 2009 15:47:59 +0100
Message-ID: <b2cc26e40912080647y5e441923n5186fd0cfff2bfdd@mail.gmail.com>
References: <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>
	 <1255722570-12803-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f198.google.com ([209.85.211.198]:42016 "EHLO
	mail-yw0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950AbZLHOrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 09:47:53 -0500
Received: by ywh36 with SMTP id 36so5436054ywh.15
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2009 06:47:59 -0800 (PST)
In-Reply-To: <1255722570-12803-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 16, 2009 at 8:49 PM, Florian Westphal <fw@strlen.de> wrote:
> Always print a warning if the syn queue is full, just like
> the tcp/ipv6 code does.
>
> The "want_cookie" define is no longer needed -- gcc
> removes the relevant branches in the CONFIG_SYN_COOKIES=n case.
>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Any comments?

Olaf
