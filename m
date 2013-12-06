From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v4] sctp: check the rto_min and rto_max
Date: Fri, 06 Dec 2013 10:50:46 +0100
Message-ID: <52A19DF6.1080808@redhat.com>
References: <529FE2AD.5020700@huawei.com> <20131205133217.GA20349@hmsreliant.think-freely.org> <52A18F6D.9010606@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47527 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756897Ab3LFJvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 04:51:13 -0500
In-Reply-To: <52A18F6D.9010606@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2013 09:48 AM, Wang Weidong wrote:

> Should I define it in net/sctp/sctp.h, so sysctl.c can use it as well.
> Or I just define it in the socket.c same as the definition in sysctl.c?

Preferably in include/net/sctp/constants.h where we already have most
other constants anyway.
