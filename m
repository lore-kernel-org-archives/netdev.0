From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of
 netns
Date: Fri, 29 May 2015 07:57:31 +0200
Message-ID: <5567FFCB.4070804@ahsoftware.de>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com> <874mnn9t12.fsf@x220.int.ebiederm.org> <555F969B.3090706@ahsoftware.de> <5562D315.9070405@6wind.com> <5562FFB0.40708@ahsoftware.de> <55631F22.90903@6wind.com> <55645097.5000509@ahsoftware.de> <556462A0.2020708@6wind.com> <556484E9.4040005@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:44123 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035AbbE2F5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 01:57:40 -0400
Received: from wandq.ahsoftware (p4FC377B0.dip0.t-ipconnect.de [79.195.119.176])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.ahsoftware.de (Postfix) with ESMTPSA id 030982C9C1CC
	for <netdev@vger.kernel.org>; Fri, 29 May 2015 07:57:38 +0200 (CEST)
In-Reply-To: <556484E9.4040005@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 26.05.2015 um 16:36 schrieb Alexander Holler:
> Am 26.05.2015 um 14:10 schrieb Nicolas Dichtel:
>> I don't understand why dumping in another netns is a problem.
>
> It isn't. I just wondered how you (or someone else) is using
> NETLINK_LISTEN_ALL_NSID, assuming it already serves a purpose. ;)

Maybe I should correct this, as I've lied because I got a bit bored. Sorry.

That dumping in another netns itself isn't a problem, but you need 
knowledge about the other namespaces. And if you have to go through all 
the pain to find and dump the interfaces in all other namenspaces by 
joining them, than there is not that much advantage in using 
NETLINK_LISTEN_ALL_NSID as you could still listen in another netns after 
the dump there too.

But there's no need to continue the discussion. I've understood that the 
patch series was only meant to reduce the number of sockets one 
otherwise would have continuously listen to.

Alexander Holler
