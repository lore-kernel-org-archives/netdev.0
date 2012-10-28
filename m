From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [RFC PATCH net-next] pktgen: clean up ktime_t helpers
Date: Sun, 28 Oct 2012 19:17:11 +0100
Message-ID: <CAD6jFURDrz+SsVcx3E3RnUCY8p7FQzot6Dvpi-mDG2MCVQiEdA@mail.gmail.com>
References: <20121026114250.GA13378@thinkbox>
	<k6jfk3$b2j$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60374 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382Ab2J1SRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 14:17:18 -0400
Received: from [78.46.5.204] (helo=sslproxy02.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TSXQD-0004Rt-Rj
	for netdev@vger.kernel.org; Sun, 28 Oct 2012 19:17:17 +0100
Received: from [209.85.215.174] (helo=mail-ea0-f174.google.com)
	by sslproxy02.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TSXQA-00049k-Oj
	for netdev@vger.kernel.org; Sun, 28 Oct 2012 19:17:14 +0100
Received: by mail-ea0-f174.google.com with SMTP id c13so1435155eaa.19
        for <netdev@vger.kernel.org>; Sun, 28 Oct 2012 11:17:11 -0700 (PDT)
In-Reply-To: <k6jfk3$b2j$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 28, 2012 at 3:31 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, 26 Oct 2012 at 11:42 GMT, Daniel Borkmann <dxchgb@gmail.com> wrote:
>> Some years ago, the ktime_t helper functions ktime_now() and ktime_lt()
>> have been introduced. Instead of defining them inside pktgen.c, they
>> should either use ktime_t library functions or, if not available, they
>> should be defined in ktime.h, so that also others can benefit from them.
>> ktime_compare() is introduced with a similar notion as in timespec_compare().
>>
>> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
>
> Looks good. This is a cleanup patch, doesn't need to be RFC, I think.

Thanks for the review, I'll resubmit it normally as non-RFC.
