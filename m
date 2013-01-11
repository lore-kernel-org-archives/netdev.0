From: Roland Dreier <roland@kernel.org>
Subject: Re: [PATCH/RFC] ipv6: fib: Drop cached routes with dead neighbours on
 fib GC
Date: Fri, 11 Jan 2013 13:10:20 -0800
Message-ID: <CAL1RGDXG=7vnf2xReeN6jR0MwSGhqcep4cN5FUApcUTJpt_mCg@mail.gmail.com>
References: <1357753459-12872-1-git-send-email-roland@kernel.org>
 <20130111134058.GB8436@order.stressinduktion.org> <20130111140119.GC8436@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog114.obsmtp.com ([74.125.245.96]:34191 "HELO
	na3sys010aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755322Ab3AKVKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 16:10:42 -0500
Received: by mail-la0-f72.google.com with SMTP id fp12so2124294lab.3
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2013 13:10:40 -0800 (PST)
In-Reply-To: <20130111140119.GC8436@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2013 at 6:01 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> The report I meant was actually not referred in this bug report:
> http://article.gmane.org/gmane.linux.network/224832
>
> ENETDOWN was also observed via bridges.

Yes, I would have to think any report of ENETDOWN with ipv6 and
bridging is quite likely to be the same issue I hit.

 - R.
