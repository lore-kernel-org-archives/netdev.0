From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check v2
Date: Thu, 9 Jun 2011 08:01:06 +0200
Message-ID: <20110609060105.GA6286@minipsycho.redhat.com>
References: <m1aaectyed.fsf@fess.ebiederm.org>
 <20110524.022406.2228892895515155850.davem@davemloft.net>
 <m1oc2spmyt.fsf@fess.ebiederm.org>
 <20110601.205940.1179055860757569997.davem@davemloft.net>
 <m11uzcidvq.fsf_-_@fess.ebiederm.org>
 <20110608162841.GB4409@minipsycho.redhat.com>
 <BANLkTiksNQ-f=qN4PhPP4qX0Saiwb-hY1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, netdev@vger.kernel.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, jesse@nicira.com
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54517 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953Ab1FIGBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 02:01:49 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTiksNQ-f=qN4PhPP4qX0Saiwb-hY1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jun 09, 2011 at 01:08:13AM CEST, xiaosuo@gmail.com wrote:
>On Thu, Jun 9, 2011 at 12:28 AM, Jiri Pirko <jpirko@redhat.com> wrote:
>>
>> Why we can't remove this right away?
>>
>
>I think the reason is this patch is a bug fix for the stable kernel,
>so we should not introduce new features or remove old features.

But for net-next if should be ok, right?

What's the reason for possibility of removing the reorder flag? Why
would user want do it?

Thanks

Jirka
>
>-- 
>Regards,
>Changli Gao(xiaosuo@gmail.com)
