From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of
 netns
Date: Fri, 22 May 2015 23:30:52 +0200
Message-ID: <555FA00C.1080207@ahsoftware.de>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>	<874mnn9t12.fsf@x220.int.ebiederm.org>	<555F969B.3090706@ahsoftware.de> <874mn448fn.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:58347 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946504AbbEVVa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 17:30:59 -0400
Received: from wandq.ahsoftware (p4FC3696B.dip0.t-ipconnect.de [79.195.105.107])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.ahsoftware.de (Postfix) with ESMTPSA id 8F0172C9C1DC
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 23:30:56 +0200 (CEST)
In-Reply-To: <874mn448fn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 22.05.2015 um 23:19 schrieb Eric W. Biederman:
> Alexander Holler <holler@ahsoftware.de> writes:
>
>> Am 08.05.2015 um 14:02 schrieb Eric W. Biederman:
>>>
>>> So I am dense.  I have read through the patches and I don't see where
>>> you tag packets from other network namespaces with a network namespace
>>> id.
>>
>> Me too,
>
> You need to use recvmsg, and then parse out the NETLINK_LISTEN_ALL_NSID
> control message.
>
> It isn't a netlink attribute that is being returned.

Hmm. :(

Maybe I should have read the kernel sources or something else where this 
is mentioned. Looks like I've understood it totally wrong.

Thanks for the explanation.

Regards,

Alexander Holler
