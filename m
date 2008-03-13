From: "Jike Song" <albcamus@gmail.com>
Subject: Re: netconsole still hangs
Date: Thu, 13 Mar 2008 15:48:04 +0800
Message-ID: <df9815e70803130048w44001478s8aa9f35edf972bc7@mail.gmail.com>
References: <20080312165717.c0879b1d.akpm@linux-foundation.org>
	 <20080312.231053.216645957.davem@davemloft.net>
	 <20080312235205.dcec2d35.akpm@linux-foundation.org>
	 <20080313.001255.01742148.davem@davemloft.net>
	 <20080313002535.9cc7b946.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	rjw@sisk.pl
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:1544 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbYCMHsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 03:48:06 -0400
Received: by wf-out-1314.google.com with SMTP id 28so3367955wff.4
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 00:48:05 -0700 (PDT)
In-Reply-To: <20080313002535.9cc7b946.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 13, 2008 at 3:25 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 13 Mar 2008 00:12:55 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>
>
>  > I asked you to do the bisect check since that's the fastest
>  > way forward at the current time.
>
>  I'm sitting here waiting to do it, but was hoping that you'd
>  know what the magical git command is.

Hello Mr Andrew,

I guess you just want this?

$ git archive -v 33f807ba0d9259e7c75c7a2ce8bd2787e5b540c7 | ( cd
<pathname> && tar xf -)

The commit prior to this one is
0953864160bdd28dfe45fd46fa462b4d2d53cb96, so please use the latter
instead if you don't want include 33f807ba0d9259e7c75c7a2ce8bd2787e5b540c7.

Best Regards,
