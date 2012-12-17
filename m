From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: openconnect triggers soft lockup in __skb_get_rxhash
Date: Mon, 17 Dec 2012 14:38:50 +0100
Message-ID: <CAD6jFUTXP-XgwFeyN11bfGcbiit=aUOoP7sSm64WK+4s6tg2TQ@mail.gmail.com>
References: <20121217005616.GA23029@shutemov.name>
	<20121216.172214.687979484434537200.davem@davemloft.net>
	<20121217014631.GA23101@shutemov.name>
	<1355719589.10504.13.camel@edumazet-glaptop>
	<20121217081121.GA24173@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <erdnetdev@gmail.com>,
	David Miller <davem@davemloft.net>, maxk@qti.qualcomm.com,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58549 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745Ab2LQNjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 08:39:06 -0500
Received: from [78.46.5.203] (helo=sslproxy01.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TkauM-0007RM-IK
	for netdev@vger.kernel.org; Mon, 17 Dec 2012 14:39:02 +0100
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy01.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TkauI-0006H7-Bs
	for netdev@vger.kernel.org; Mon, 17 Dec 2012 14:38:58 +0100
Received: by mail-ee0-f46.google.com with SMTP id e53so3228356eek.19
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2012 05:38:51 -0800 (PST)
In-Reply-To: <20121217081121.GA24173@shutemov.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2012 at 9:11 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Sun, Dec 16, 2012 at 08:46:29PM -0800, Eric Dumazet wrote:
>> On Mon, 2012-12-17 at 03:46 +0200, Kirill A. Shutemov wrote:
>> > On Sun, Dec 16, 2012 at 05:22:14PM -0800, David Miller wrote:
>> > >
>> > > Already fixed in Linus's tree by:
>> > >
>> > > From 499744209b2cbca66c42119226e5470da3bb7040 Mon Sep 17 00:00:00 2001
>> >
>> > No, it's not. I use up-to-date (2a74dbb) Linus tree with the patch in and
>> > still see the issue.
>> >
>>
>> Coud you try the following one liner ?
>
> Works for me. So far no problems.
>
> Reported-and-tested-by: Kirill A. Shutemov <kirill@shutemov.name>

I can confirm the same, ran into the same issue when being connected
via VPN and seems stable now.

Tested-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
