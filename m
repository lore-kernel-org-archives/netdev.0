From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check v2
Date: Thu, 9 Jun 2011 07:08:13 +0800
Message-ID: <BANLkTiksNQ-f=qN4PhPP4qX0Saiwb-hY1A@mail.gmail.com>
References: <m1aaectyed.fsf@fess.ebiederm.org> <20110524.022406.2228892895515155850.davem@davemloft.net>
 <m1oc2spmyt.fsf@fess.ebiederm.org> <20110601.205940.1179055860757569997.davem@davemloft.net>
 <m11uzcidvq.fsf_-_@fess.ebiederm.org> <20110608162841.GB4409@minipsycho.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, netdev@vger.kernel.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, jesse@nicira.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51390 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103Ab1FHXIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 19:08:34 -0400
Received: by bwz15 with SMTP id 15so846122bwz.19
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 16:08:33 -0700 (PDT)
In-Reply-To: <20110608162841.GB4409@minipsycho.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 9, 2011 at 12:28 AM, Jiri Pirko <jpirko@redhat.com> wrote:
>
> Why we can't remove this right away?
>

I think the reason is this patch is a bug fix for the stable kernel,
so we should not introduce new features or remove old features.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
