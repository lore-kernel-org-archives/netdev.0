From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of netns
Date: Fri, 22 May 2015 16:19:08 -0500
Message-ID: <874mn448fn.fsf@x220.int.ebiederm.org>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
	<874mnn9t12.fsf@x220.int.ebiederm.org>
	<555F969B.3090706@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58092 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945931AbbEVVYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 17:24:02 -0400
In-Reply-To: <555F969B.3090706@ahsoftware.de> (Alexander Holler's message of
	"Fri, 22 May 2015 22:50:35 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Holler <holler@ahsoftware.de> writes:

> Am 08.05.2015 um 14:02 schrieb Eric W. Biederman:
>>
>> So I am dense.  I have read through the patches and I don't see where
>> you tag packets from other network namespaces with a network namespace
>> id.
>
> Me too,

You need to use recvmsg, and then parse out the NETLINK_LISTEN_ALL_NSID
control message.

It isn't a netlink attribute that is being returned.

Eric
