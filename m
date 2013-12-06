From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH v4] sctp: check the rto_min and rto_max
Date: Fri, 6 Dec 2013 17:52:45 +0800
Message-ID: <52A19E6D.1090503@huawei.com>
References: <529FE2AD.5020700@huawei.com> <20131205133217.GA20349@hmsreliant.think-freely.org> <52A18F6D.9010606@huawei.com> <52A19DF6.1080808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:59921 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754029Ab3LFJx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 04:53:29 -0500
In-Reply-To: <52A19DF6.1080808@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/6 17:50, Daniel Borkmann wrote:
> On 12/06/2013 09:48 AM, Wang Weidong wrote:
> 
>> Should I define it in net/sctp/sctp.h, so sysctl.c can use it as well.
>> Or I just define it in the socket.c same as the definition in sysctl.c?
> 
> Preferably in include/net/sctp/constants.h where we already have most
> other constants anyway.
> 

Nice, Thanks for your suggestion.

Regards.
Wang
> 
