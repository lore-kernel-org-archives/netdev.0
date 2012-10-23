From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH net-next 2/2] packet: minor: make if case unlikely
Date: Tue, 23 Oct 2012 19:22:04 +0200
Message-ID: <CAD6jFURh1jk_3n5bhdxma7NCGgbunnajT2V==+bnMUg9gDgY+Q@mail.gmail.com>
References: <20121023115833.GB8664@thinkbox>
	<20121023.131253.779417489113821973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44690 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756056Ab2JWRWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:22:11 -0400
Received: from [78.46.5.204] (helo=sslproxy02.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TQiB8-0002lD-Oc
	for netdev@vger.kernel.org; Tue, 23 Oct 2012 19:22:10 +0200
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy02.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TQiB5-0003ml-Lj
	for netdev@vger.kernel.org; Tue, 23 Oct 2012 19:22:07 +0200
Received: by mail-ee0-f46.google.com with SMTP id b15so1506679eek.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 10:22:04 -0700 (PDT)
In-Reply-To: <20121023.131253.779417489113821973.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 23, 2012 at 7:12 PM, David Miller <davem@davemloft.net> wrote:
> From: Daniel Borkmann <dxchgb@gmail.com>
> Date: Tue, 23 Oct 2012 13:58:34 +0200
>
>> This patch fixes the character width of max. 80 chars and also marks the
>> if-statement as unlikely since those flags are not supported for the receive
>> path anyway.
>>
>> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
>
> Please, don't submit patches like this.
>
> 80 characters is a soft "guidelline" there is no strict requirement
> for it.

Good to know.

Thanks for the feedback.
