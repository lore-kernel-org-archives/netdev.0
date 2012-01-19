From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: RE: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 20:40:32 +0100
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC1644FD0833@ESESSCMS0356.eemea.ericsson.se>
References: <201201191207.10207.hans.schillstrom@ericsson.com>,<20120119.124002.1964667767933832927.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:60551 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932675Ab2ASTkf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 14:40:35 -0500
In-Reply-To: <20120119.124002.1964667767933832927.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Date: Thu, 19 Jan 2012 12:07:09 +0100
>
>> Closing of a namespace (container) can be delayed by ~ 2 minutes
>> due to tcp timers ex tcp time wait (and of cource other things too).
>>
>> I think there should be some kind of "forced close" of the Network stack
>> in ex free_nsproxy()
>
>I think this is unwise.
>
>Keeping the timewait sockets around is necessary to absorb any lingering
>packets in the network meant for those sockets.
>
>If you truncate this activity, and then try to create another socket with
>the same ID you'll run into the very problems time-wait is meant to
>solve.
>
>It's an unfortunate delay, but one you will have to live with.

I think the whole clean up is to weak of the name space, there is too many things that
can go wrong and they do.

I was more thinking of a way to make a forced close, 
ex by cleaning the stack where time wait was one point.
