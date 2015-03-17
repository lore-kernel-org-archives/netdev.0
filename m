From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Fw: [Bug 94991] New: TCP bug creates additional RTO in very
 specific condition
Date: Tue, 17 Mar 2015 12:49:49 -0400
Message-ID: <CADVnQy=HA1ZYSuOOzEZavGCZfOF5_L+ExtDoJCw7nzDCj9+M8A@mail.gmail.com>
References: <20150317083333.65b7af40@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, matiasb@gmail.com,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:34814 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932524AbbCQQtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 12:49:50 -0400
Received: by qcaz10 with SMTP id z10so14118801qca.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 09:49:49 -0700 (PDT)
In-Reply-To: <20150317083333.65b7af40@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 17, 2015 at 11:33 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> https://bugzilla.kernel.org/show_bug.cgi?id=94991
>             Bug ID: 94991
>            Summary: TCP bug creates additional RTO in very specific
>                     condition

Thanks for forwarding. I posted the following on the bug:

2.6.32 is over 5 years old (Dec 2009). I suspect this bug is in the
old FRTO code that Yuchung removed when he rewrote FRTO from scratch
in 2013. Can you please test a newer version of the kernel (preferably
3.19 but at least 3.12 or newer) to see if this bug is still around?
Thanks!

neal
