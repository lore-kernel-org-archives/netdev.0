From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH -next] bonding: fix error return code in bond_enslave()
Date: Fri, 23 Aug 2013 15:44:00 +0200
Message-ID: <52176720.60300@redhat.com>
References: <CAPgLHd96k-qncCXzzVogwtmMdaYUDsMShdX52YSLAdbTiN1uEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62495 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754918Ab3HWNrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 09:47:46 -0400
In-Reply-To: <CAPgLHd96k-qncCXzzVogwtmMdaYUDsMShdX52YSLAdbTiN1uEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2013 04:45 AM, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code in the add bond vlan ids error
> handling case instead of 0, as done elsewhere in this function.
> 
> Introduced by commit 1ff412ad7714f6952f76ffd77f0a7f2f563288a1.
> (bonding: change the bond's vlan syncing functions with the standard ones)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Oops, missed the error code. Thanks :-)

Acked-by: Nikolay Aleksandrov <nikolay@redhat.com>
