From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8961] New: BUG triggered by oidentd in netlink
 code
Date: Sun, 02 Sep 2007 12:56:12 +0200
Message-ID: <46DA96CC.3080402@trash.net>
References: <E1IRghZ-0004EL-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: link@miggy.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46385 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754702AbXIBK5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 06:57:41 -0400
In-Reply-To: <E1IRghZ-0004EL-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Patrick McHardy <kaber@trash.net> wrote:
>   
>> Thanks. I'm not sure either, it would require two concurrent requests
>> to be processed, but AFAICS oidentd only uses a single netlink socket.
>> Perhaps multiple running instances or something else using the inet_diag
>> interface?
>>     
>
> Since identd serves requests from the outside world it is
> quite possible for two identd instances to run simultaneously
> serving two requests.
>
> I'm not familiar with oidentd but this is certainly pidentd
> works.

Right, I forgot about inetd. Thanks Herbert :)

