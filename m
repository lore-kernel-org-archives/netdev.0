From: "Hannes Eder" <hannes@hanneseder.net>
Subject: Re: [PATCH 03/27] drivers/net: fix sparse warning: returning void-valued expression
Date: Fri, 26 Dec 2008 15:39:59 +0100
Message-ID: <154e089b0812260639t65968a2crbbf6c0a8f8d468cf@mail.gmail.com>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	 <20081222191517.11807.20718.stgit@vmbox.hanneseder.net>
	 <20081225.161740.10052019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:3040 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbYLZOkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 09:40:01 -0500
In-Reply-To: <20081225.161740.10052019.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 26, 2008 at 1:17 AM, David Miller <davem@davemloft.net> wrote:
> From: Hannes Eder <hannes@hanneseder.net>
> Date: Mon, 22 Dec 2008 20:15:17 +0100
>
>> Fix this sparse warning:
>>
>>   drivers/net/niu.c:8850:2: warning: returning void-valued expression
>>
>> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
>
> Can we just fix sparse not to generate this warning?  It's
> marginal, at best.  C++ even explicitly defines this as valid
> and last time I brought this up Linus even agreed.
>
> The types match, the function returns void and it is returning a void,
> what is the problem?

after reading the following thread I decided to submit such type of patches:

On Thu, 1 May 2008 at 13:53:39 +0100, Al Viro wrote:
> On Thu, May 01, 2008 at 03:42:14PM +0300, Boaz Harrosh wrote:
> > > 3.  6.8.6.4(1): A return statement with an expression shall not appear in
> > > a function whose return type is void.
> > >
> >
> > Please forgive my ignorance, where is this quote from?
>
> C99.  I don't have C90 in front of me, so I can't give you exact quote from
> there, but it's been explicitly banned in C90 as well.

see http://lkml.org/lkml/2008/5/1/112
